from datetime import datetime

import cx_Oracle
import pandas as pd
import pandas.io.sql as psql

from db_conn.connBase import ConnBase
from core_config import configuration, app_service_config
from utilities import Logger


class OracleConn(ConnBase):

    def __init__(self, ConnectionName:str,time_out:int = None):
        super().__init__(ConnectionName)
        self._config = configuration.oracle_database[ConnectionName]
        self._time_out = time_out
        # var Error
        self._errorMsg = None
        #connect
        self._dns = cx_Oracle.makedsn(
            self._config.host, self._config.port, service_name=self._config.service_name
        )
        
        self._conn = None
        self._cursor = None
        try:
            self._conn = cx_Oracle.connect(
                user=self._config.username,
                password=self._config.password,
                dsn=self._dns,
                encoding="UTF-8",
                nencoding="UTF-8"
            )
            # if self._time_out:
            #     self._time_out *= 1000
            #     self._conn.callTimeout = self._time_out
            # print(self._conn)
            self._cursor = self._conn.cursor()
            self.logger = Logger().logger

        except cx_Oracle.DatabaseError as e:
            self.logger.exception(f'Error: {e}')
            self.__exit__
        except Exception  as e:
            self.logger.exception(f'Error: {e}')
            self.__exit__



    def __enter__(self):
        return self


    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close
        self._clear_attributes()

    def __del__(self):
        self._clear_attributes()

    def _clear_attributes(self):
        """Clear object attributes during exit."""
        attributes = [
            '_config', '_conn', '_cursor', 
            '_errorMsg','_time_out',
            'logger']
        for attr in attributes:
            setattr(self, attr, None)

    @property
    def maskDNS(self):
        return self._dns

    @property
    def cursor(self):
        return self._cursor
    
    @property
    def connection(self):
        return self._conn
    
    @property
    def commit(self):
        self.connection.commit()

    @property
    def close(self):
        if self._cursor:
            self._cursor.close()
        if self._conn:
            self._conn.close()

    @property
    def is_connected(self):
        try:
            self.execute("SELECT 1 FROM DUAL")
            return True
        except cx_Oracle.Error as e:
            self.logger.exception(e)
            self.close
            return False

    


    @property
    def db_version(self):
        return self.connection.version

    @property
    def err_msg(self):
        return self._errorMsg  
    
    def execute(self, sql, params=None):
        try:
            self.cursor.execute(sql, params or ())
        except cx_Oracle.DatabaseError as e:
            self.logger.exception(e)
            self.close
        except Exception  as e:
            self.logger.exception(e)
            self.close
        # finally:
        #     self.close

    @property
    def fetchall(self):
        return self.cursor.fetchall()


    @property
    def fetch_all_df(self) -> pd.DataFrame:
        names = [ x[0] for x in self.cursor.description]
        rows = self.fetchall
        return pd.DataFrame( rows, columns=names)

    @property
    def fetchone(self):
        return self.cursor.fetchone()

    def query(self, sql, params=None) -> pd.DataFrame:
        self.execute(sql, params or ())
        return self.fetchall()

    @property    
    def rows(self):
        return self.cursor.rowcount
        

    def execute_procedure(self, procedure, params = None):
        try:
            if params is None:
                self.cursor.callproc(procedure)
            else: 
                self.cursor.callproc(procedure,params)
        
        except Exception  as e:
            self.logger.exception(e)
            self.close 

    def execute_procedure_param(self,procedure,in_params:list,out_params_type:dict):
        # Prepare parameters for callproc
        out_results = {} 
        out_params = {}
        try:
            # Convert output parameters to cx_Oracle variables
            for key, param_type in out_params_type.items():
                if param_type == "VARCHAR2":
                    out_params[key] = self.cursor.var(cx_Oracle.STRING)
                elif param_type == "NUMBER":
                    out_params[key] = self.cursor.var(cx_Oracle.NUMBER)
                elif param_type == "CURSOR":
                    out_params[key] = self.cursor.var(cx_Oracle.CURSOR)
                else:
                    # Default to VARCHAR2 if type not specified
                    out_params[key] = self.cursor.var(cx_Oracle.STRING)
            # Combine input parameters with output parameters
            params = in_params + list(out_params.values())
            
            # Call the procedure
            self.cursor.callproc(procedure, params)
            
            # Fetch output parameter values after procedure execution
            out_results = {name: var.getvalue() for name, var in out_params.items()}
        except Exception  as e:
            self.logger.exception(e)
            self.close 
        return out_results


    def fetch_data_from_prc(self,procedure, params = None):
        l_cur = self.cursor.var(cx_Oracle.CURSOR)
        params.append(l_cur)
        data = self.cursor.callproc(procedure,params)
        return list(data)
    
    def get_col_name(self, tableName:str) -> list:
        self.execute(f"SELECT column_name FROM {app_service_config.orl_sys_tbl_col} WHERE table_name = '{tableName.upper()}'")
        columns = [row[0] for row in self.cursor]
        return columns
    
    def check_column_exist(self, tableName:str, column:str) -> bool:
         self.execute(f"SELECT column_name FROM {app_service_config.orl_sys_tbl_col} WHERE table_name = '{tableName.upper()}' and column_name = '{column.upper()}'")
         result = self.fetchone
         return bool(result)
    
    def check_table_exist(self, tableName:str) -> bool:
         self.cursor.execute(f"SELECT table_name FROM {app_service_config.orl_sys_tbl_tbl} WHERE table_name = '{tableName.upper()}'")
         result = self.fetchall
         return bool(result)
    
    def truncate_table(self, tableName:str):
        self.execute(f"TRUNCATE TABLE {tableName.upper()}")

    def tabel_to_df(self,tableName:str) -> pd.DataFrame:
        df = psql.read_sql_query(f"SELECT * FROM {tableName}", self.connection)
        return df
    
    def df_to_table(self, df: pd.DataFrame, tableName: str) -> bool:
        try:
            # Kiểm tra nếu DataFrame trống
            if df.empty:
                self._errorMsg = f"DataFrame is empty, no data to insert into {tableName}."
                return False

            # Ghi dữ liệu vào bảng
            df.to_sql(tableName, self.connection, if_exists='replace', index=False)

            # Kiểm tra số lượng bản ghi đã được chèn vào bảng
            query = f"SELECT COUNT(*) FROM {tableName}"
            result = pd.read_sql(query, self.connection)

            if result.iloc[0, 0] > 0:
                self._errorMsg = f"Data has been successfully inserted into {tableName}."
                return True
            else:
                self._errorMsg = f"Data insertion failed, no records found in {tableName}."
                return False

        except Exception as e:
            self.logger.exception(e)
            self.close
            return False
        
    # Đọc dữ liệu từ SQL bằng câu lệnh SQL
    def read_sql_query(self, sql_query: str, index_col=None, params=None) -> pd.DataFrame:
        """
        Executes an SQL query and returns the result as a DataFrame.

        :param sql_query: SQL query string to be executed.
        :param index_col: Column to set as index (optional).
        :param params: Parameters to pass to the SQL query (optional).
        :return: DataFrame containing the query result.
        """
        try:
            df = psql.read_sql_query(sql_query, self.connection, index_col=index_col, params=params)
            return df
        except Exception as e:
            self.logger.exception(e)
            self.close
            return None

    # Đọc dữ liệu từ một bảng SQL
    def read_sql_table(self, table_name: str, schema=None, index_col=None) -> pd.DataFrame:
        try:
            df = psql.read_sql_table(table_name, self.connection, schema=schema, index_col=index_col)
            return df
        except Exception as e:
            self.logger.exception(e)
            self.close
            return None

    # Đọc SQL (linh hoạt)
    def read_sql(self, sql: str, index_col=None) -> pd.DataFrame:
        try:
            df = psql.read_sql(sql, self.connection, index_col=index_col)
            return df
        except Exception as e:
            self.logger.exception(e)
            self.close
            return None

    # Ghi dữ liệu vào SQL
    def to_sql(self, df: pd.DataFrame, table_name: str, if_exists='replace', index=False):
        try:
            df.to_sql(table_name, self.connection, if_exists=if_exists, index=index)
            self._errorMsg = f"DataFrame successfully written to table: {table_name}"
        except ValueError as e:
            self.logger.exception(f"ValueError: {e}")
            self.close
            return False
        except Exception as e:
            self.logger.exception(f"Error writing DataFrame to table: {e}")
            self.close
            return False
        return True

    # Tạo câu lệnh CREATE TABLE từ DataFrame
    def pd_get_schema(self, df: pd.DataFrame, table_name: str, flavor=None) -> str:
        try:
            schema = psql.get_schema(df, table_name, con=self.connection, flavor=flavor)
            return schema
        except Exception as e:
            self.logger.exception(e)
            self.close
            return ""

    # Thực thi câu lệnh SQL trực tiếp
    def pd_execute(self, sql: str):
        try:
            psql.execute(sql, self.connection)
        except Exception as e:
            self.logger.exception(e)
            self.close


    def execute_script_list(self, script_list: list) -> list:
        dataArr = []
        # print(sriptArr)
        for i in range(len(script_list)):
            data = None
            # print(dataArr[i])
            self.execute(script_list[i])
            
            names = [ x[0] for x in self.cursor.description]
            rows = self.cursor.fetchall()

            data = pd.DataFrame( rows, columns=names)

            # print(data)

            dataArr.append(data)  
            data = None
            
        return dataArr
    
    def get_data_type_table(self, tableName:str) -> pd.DataFrame:
        """Get data Type from table"""
        self.execute(f"""
                                SELECT COLUMN_NAME
                                    , DATA_TYPE
                                    , DATA_LENGTH as MAX_LENGTH
                                    , DATA_PRECISION as PRECISION
                                    ,DATA_SCALE as SCALE
                                FROM {app_service_config.orl_sys_tbl_col}
                                WHERE table_name = '{tableName.upper()}'
                            """)
        return self.fetch_all_df
    
    def execute_import_data(self, sql:str, df:pd.DataFrame):
        try:
            records = df.to_dict("records")
            for record in records:
                for key, value in record.items():
                    if value is None or value == '<NULL>':
                        record[key] = None
                    else: 
                        record[key] = value
            self.cursor.executemany(sql, records)
        except Exception as e:
            self.logger.exception(f"Error import data to database",e)
        finally:
            self.commit

    def import_log(self,procedure, params) -> int:
        out_value = self.cursor.var(cx_Oracle.NUMBER)
        params.append(out_value)
        self.cursor.callproc(procedure,params)
        return out_value.getvalue()

    def schedule_process_data(self, sql:str, params) -> pd.DataFrame:
        self.execute(sql, params)
        return self.fetch_all_df
    
    def execute_prc_with_cursor(self, procedure, params=None) -> pd.DataFrame:
        """Get data from cursor"""
        out_cursor = self.cursor.var(cx_Oracle.CURSOR)
        params.append(out_cursor)
        self.cursor.callproc(procedure,params)
        result_cursor = out_cursor.getvalue()
        names = [ x[0] for x in result_cursor.description]
        rows = result_cursor.fetchall()
        return pd.DataFrame( rows, columns=names)
        
        
    

    