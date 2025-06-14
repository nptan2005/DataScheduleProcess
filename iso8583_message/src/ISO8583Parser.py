import copy
from typing import TextIO
from ..ISO8583Message import *

class ISO8583Parser:
    def __init__(self, fields:dict[str,ISO8583Field]):
        self.fields = fields

    def parseHeader(self,headermsg:bytes) -> tuple[ISO8583Field,int]:
        header_length = bytes_to_int(headermsg)
        header = copy.deepcopy(self.fields["h"])
        header.encodeValue = headermsg
        header.decodeValue = header_length
        return header, header_length
    # parseHeader

    def parseMTI(self,msg:str) -> ISO8583Field:
        mti = copy.deepcopy(self.fields["t"])
        mti.encodeValue = msg
        mti.decodeValue = bytes_to_accii(msg)
        return mti
    # parseMTI

    def parseBitmap(self,fullmessage:str, index:int) -> tuple[ISO8583Field, int]:
        """
            return Primary Bitmap and Secondary bitmap (if any)
        """
        bitmap = copy.deepcopy(self.fields["p"])
        if "p" in self.fields:
            primary_bitmap = fullmessage[index:index + bitmap.field_length]
            primary_bitmap_bits = bytes_to_binary(primary_bitmap)
            index += bitmap.field_length

        # Check for Secondary Bitmap
        secondary_bitmap_bits = ''
        if primary_bitmap_bits[0] == '1' and "s" in self.fields:
            secondary_bitmap_obj = copy.deepcopy(self.fields["s"])
            secondary_bitmap = fullmessage[index:index + secondary_bitmap_obj.field_length]
            secondary_bitmap_bits = bytes_to_binary(secondary_bitmap)
            
            index += secondary_bitmap_obj.field_length

        # Combine bitmaps
        bitmap_bits = primary_bitmap_bits + secondary_bitmap_bits
        bitmap_fields = [i + 1 for i, bit in enumerate(bitmap_bits) if bit == '1']

        bitmap.encodeValue = bitmap_bits
        bitmap.decodeValue = bitmap_fields

        return bitmap,index
    # parseBitmap

    def parseTLVContent(self,bit, tag, length, value, description: None) -> dict:
        """(Tag-Length-Value)
        func need override by define of bitmap
        return dict 
        {
            "Bit": bit,
            "Description": description,
            "Tag": tag,
            "Length": length,
            "Value": value
        }
        Tag, Length, Value >>> TLV
        """
        return {
            "Bit": bit,
            "Description": description,
            "Tag": tag,
            "Length": length,
            "Value": value
            }

    def parse_tlv(self,bit, data:hex) -> list:
        """Parse (Tag-Length-Value)"""
        # Phương thức để phân tích dữ liệu TLV
        index = 0
        parsed_data = []
        
        while index < len(data):
            # Parse Tag (2 bytes)
            tag = data[index:index+4] # JCB dùng tag 2byte (4 ký tự hex)
            index += 4

            # Parse Length (1 bytes)
            length = int(data[index:index+2],16)
            # Mỗi byte là 2 ký tự hex
            index += 2

            # Parse Value (lấy value dựa trên length)
            value_hex = data[index:index+length*2]
            # Mỗi byte là 2 ký tự hex
            index += length*2
            description = ''
            # Parse Value từ hex
            # if tag == ""
            fieldDictContent = self.parseTLVContent(bit=bit, tag=tag,length=length,value=value_hex,description=description)

            parsed_data.append(fieldDictContent)
        return parsed_data
    # parse_tlv

    def parse_track_data(self, track_data):

        # Chuyển đổi chuỗi nhị phân thành chuỗi ký tự
        decoded_string = ''.join(chr(int(track_data[i:i+8], 2)) for i in range(0, len(track_data), 8))
        return decoded_string
    # parse_track_data
    
    

    def custom_field_switcher(self,fieldNumber:int, data:bytes):
        """
        func need override by define of bitmap
        return list( 
        {
            "Tag": tag,
            "Length": length,
            "Value": value,
            "Description": description,
        })
        if not overrude default return string with hex format
        """
        return data
    # parse_custom_field

    

    def parse_additional_field(self, fieldNumber, msg:bytes) -> list:
        return msg

    def parseField(self, bitData:ISO8583Field, msg:bytes, msgLen:int)-> ISO8583Field:
        bitData.encodeValue = msg
        #convert data by dataType
        if bitData.data_type == "N":
            bitData.decodeValue = int(msg.decode('ascii').strip())
        # elif bitData.data_type in ["A","B","S","Z","AN","ANS","AS"]:
        else:
            if bitData.field_number in [43,54,97]:
                custom_data = self.custom_field_switcher(bitData.field_number,data=msg)
                bitData.decodeValue = custom_data
            elif bitData.field_number in [54,55,62,63]:
                tlv_data = self.parse_tlv(bit=bitData.field_number,data=bytes_to_hex(msg))
                bitData.decodeValue = tlv_data
                # print(f'>>>>[{bitData.field_number}]{bytes_to_accii(msg)}')
            elif bitData.field_number in [35, 36, 95]:
                binary_string = bytes_to_binary(msg,msgLen * 8) 
                track_data = self.parse_track_data(binary_string)
                bitData.decodeValue = track_data
            elif bitData.field_number in [48, 62, 123, 124, 125, 126]:
                additional_data = self.parse_additional_field(bitData.field_number, msg)
                bitData.decodeValue = additional_data
            else:
                bitData.decodeValue =  bytes_to_accii(msg)
        
   
        return bitData
    # parseField



    def parseISOMessage(self,message):
        index = 0
        parsed_data = dict[str,ISO8583Field]
        parsed_data = {}
        try:

            # Get Header
            if "h" in self.fields:
                headerField = self.fields["h"]
                if headerField.field_length > 0:
                    parsed_data["Header"], lenOfMsg = self.parseHeader(message[index:index + headerField.field_length])
                
                    index += headerField.field_length
                    # print(f'len of Message: {lenOfMsg}')
                    message = message[index:lenOfMsg + headerField.field_length]
                index = 0
            # Parse MTI
            if "t" in self.fields:
                parsed_data['MTI'] = self.parseMTI(message[index:index + 4])

                a = parsed_data['MTI']
                print(f'MTI = {a.decodeValue}')
                index += 4

            
            # Parse Bitmap
            bitmap, index = self.parseBitmap(message,index)
            
            parsed_data['bitmap'] = bitmap

            print(f'BitMap= {bitmap.decodeValue}')

            # Parse fields based on bitmap
            for i, bit in enumerate(bitmap.encodeValue):
                if bit == '1':
                    field_number = i + 1
                    field = self.fields.get(str(field_number))
                    if field:
                        if field.prefix == 'L':
                            if index + 1 <= len(message):
                                length = int(message[index:index + 1].decode('ascii'))
                                index += 1
                            else:
                                raise ValueError(f"Invalid length for field {field_number}")
                        elif field.prefix == 'LL':
                            if index + 2 <= len(message):
                                length = int(message[index:index + 2].decode('ascii'))
                                # print(f'len of Field {field_number} = {length}')
                                index += 2
                            else:
                                raise ISO8583Error(field_number,length,index, f"Invalid length for field {field_number}")

                        elif field.prefix == 'LLL':
                            if index + 3 <= len(message):
                                length = int(message[index:index + 3].decode('ascii'))
                                # print(f'len of Field {field_number} = {length}')
                                index += 3
                            else:
                                raise ISO8583Error(field_number,length,index, f"Invalid length for field {field_number}")
                        else:
                            length = field.field_length

                        if index + length <= len(message):
                            # field_data = message[index:index + length].decode('latin-1')
                                
                            parsed_data[str(field_number)] = self.parseField(copy.deepcopy(field),message[index:index + length],length)
                            
                            index += length
                        else:
                            raise ISO8583Error(field_number,length,index, f"Invalid length for field {field_number}")
        except Exception as e:
            print (f'bit {field_number}, len {length}, p {index}, error {e} ')
            # if field_number == 55:
            #     print(f'[Bit {field_number}] Bytes = {message[index:index + length]}')
            #     # {bytes_to_accii(msg)}
            #     # bytes_to_hex(msg)
            #     print(f'[Bit {field_number}] Bytes = {bytes_to_hex(message[index:index + length])}')
            #     # print(f'[Bit {field_number}] acci = {(message[index:index + length]).decode()}')
        return parsed_data, lenOfMsg + 4
    # parseISOMessage
    
    def print_tvr_field(self,
        tvr: dict[str, str],
        stream: TextIO,
        indent:int
        ) -> None:
        if indent > 12:
            indent = 12
        else:
            indent += 1
        for bit_description, bit_value in tvr.items():
            stream.write(f"{' ' * indent}{bit_description:<47}: {'Yes' if bit_value == '1' else 'No':<3} ({repr(bit_value)})\n")



    # print_tvr_field

    def print_tlv_field(self,
        tlv: dict[str, any],
        stream: TextIO,
        indent: int,
        ) -> None:
        if indent > 9:
            indent = 9
        else:
            indent += 1
       
        stream.write(f"{' ' * indent}Tag        : {tlv['Tag']}\n")
        if 'Description' in tlv:
            stream.write(f"{' ' * indent}Description: {tlv['Description']}\n")
        stream.write(f"{' ' * indent}Length     : {tlv['Length']}\n")
        if isinstance(tlv['Value'],dict):
            stream.write(f"{' ' * indent}Value      :\n")
            self.print_tvr_field(tlv['Value'],stream,indent)
        elif isinstance(tlv['Value'],list):
            self.print_list_additional(tlv['Value'],stream,indent)
        else:
            stream.write(f"{' ' * indent}Value      : {repr(tlv['Value'])}\n")

    # print_tlv_field

    def print_custom_field(self,
        data: dict[str, any],
        stream: TextIO,
        indent: int,
        ) -> None:
        if indent > 9:
            indent = 9
        else:
            indent += 1
       
        stream.write(f"{' ' * indent}Field       : {data['Field']}\n")
        if 'Description' in data:
            stream.write(f"{' ' * indent}Description: {data['Description']}\n")
        stream.write(f"{' ' * indent}Length     : {data['Length']}\n")
        if isinstance(data['Data'],dict):
            stream.write(f"{' ' * indent}Data       :\n")
            self.print_tvr_field(data['Data'],stream,indent)
        elif isinstance(data['Data'],list):
            self.print_list_additional(data['Data'],stream,indent)
        else:
            stream.write(f"{' ' * indent}Data       : {repr(data['Data'])}\n")

    # print_custom_field

    def print_dict(self,
        dictData: dict[any, any],
        stream: TextIO,
        indent: int,
        ) -> None:
        if indent > 12:
            indent = 12
        else:
            indent += 1
        for key, item in dictData.items():
            stream.write(f"{' ' * indent}{key:12s}        : {item}\n")

    # print_dict

    def print_list_additional(self,
        listData: list,
        stream: TextIO,
        indent: int,
        ) -> None:
        indent+=2
        for data_element in listData:
            if isinstance(data_element,dict):
                self.print_dict(data_element,stream,indent)
            else:
                stream.write(f"{' ' * indent}{data_element}\n")


    # print_dict_additional

    def print_iso_field(self,
    field: ISO8583Field,
    stream: TextIO,
    line_width: int
    ) -> None:
        indent = 5
        
        stream.write(f"Bit{field.field_number:3d}")

        if field.data_type:
            desc = field.data_type
            stream.write(f" | {desc:<45}")
            indent += 45 + 1

        stream.write(": ")

        if isinstance(field.decodeValue, list) and all(isinstance(item, dict) for item in field.decodeValue):
            stream.write("\n")
            for item in field.decodeValue:
                if all(k in item for k in ["Tag", "Length", "Value","Description"]):
                    self.print_tlv_field(item, stream, indent)
                elif all(k in item for k in ["Field", "Length", "Data","Description"]):
                    self.print_custom_field(item, stream, indent)
        else:
            rep = repr(field.decodeValue)

            if len(rep) + indent > line_width:
                stream.write(f"\n{' ' * indent}{rep}\n")
            else:
                stream.write(f"{rep}\n")
    # print_iso_field
