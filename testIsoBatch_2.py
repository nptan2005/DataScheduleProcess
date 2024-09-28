import iso8583
import os
import configparser

import iso8583.specs
from iso8583.specs import default_ascii as spec
from datetime import datetime
import binascii
from utilities import Utils as utils

# Tạo đặc tả tùy chỉnh
custom_spec = spec.copy()
custom_spec['h'] = {'len_type': 'fixed', 'max_len': 4, 'data_enc': 'ascii', 'len_enc': 'ascii'}
custom_spec['p'] = {'len_type': 'fixed', 'max_len': 16, 'data_enc': 'ascii', 'len_enc': 'ascii'}
custom_spec['2'] = {'len_type': 'llvar', 'max_len': 19, 'data_enc': 'ascii', 'len_enc': 'ascii'}
custom_spec['3'] = {'len_type': 'fixed', 'max_len': 6, 'data_enc': 'ascii', 'len_enc': 'ascii'}
custom_spec['4'] = {'len_type': 'fixed', 'max_len': 12, 'data_enc': 'ascii', 'len_enc': 'ascii'}
custom_spec['7'] = {'len_type': 'fixed', 'max_len': 10, 'data_enc': 'ascii', 'len_enc': 'ascii'}
custom_spec['11'] = {'len_type': 'fixed', 'max_len': 6, 'data_enc': 'ascii', 'len_enc': 'ascii'}
custom_spec['12'] = {'len_type': 'fixed', 'max_len': 6, 'data_enc': 'ascii', 'len_enc': 'ascii'}
custom_spec['13'] = {'len_type': 'fixed', 'max_len': 4, 'data_enc': 'ascii', 'len_enc': 'ascii'}
custom_spec['32'] = {'len_type': 'llvar', 'max_len': 11, 'data_enc': 'ascii', 'len_enc': 'ascii'}
custom_spec['39'] = {'len_type': 'fixed', 'max_len': 2, 'data_enc': 'ascii', 'len_enc': 'ascii'}
custom_spec['41'] = {'len_type': 'fixed', 'max_len': 8, 'data_enc': 'ascii', 'len_enc': 'ascii'}
custom_spec['42'] = {'len_type': 'fixed', 'max_len': 15, 'data_enc': 'ascii', 'len_enc': 'ascii'}
custom_spec['49'] = {'len_type': 'fixed', 'max_len': 3, 'data_enc': 'ascii', 'len_enc': 'ascii'}
custom_spec['52'] = {'len_type': 'fixed', 'max_len': 16, 'data_enc': 'ascii', 'len_enc': 'ascii'}
custom_spec['53'] = {'len_type': 'fixed', 'max_len': 16, 'data_enc': 'ascii', 'len_enc': 'ascii'}
custom_spec['62'] = {'len_type': 'llvar', 'max_len': 999, 'data_enc': 'ascii', 'len_enc': 'ascii'}
reportPath = os.path.join('Data','Export_Data')

path = 'TEST_ISO_BATCH'
def fullPath(fileName):
    now = datetime.now()
    _father_path = os.path.join (reportPath, path)
    _fileName = fileName + '_' + now.strftime("%Y%m%d_%H%M%S")
    try:
        _folderName = now.strftime("%Y%m%d")
        _path = os.path.join (_father_path, _folderName) 
        utils.create_directory(_path)
        return os.path.join (_path, _fileName)
    except Exception  as e:
        print(e)
        return os.path.join(_father_path, _fileName)
class ISO8583Message:
    def __init__(self, mti, fields):
        self.mti = mti
        self.fields = fields

    def get_message_string(self):
        message = self.mti
        for field_num, field_data in self.fields.items():
            field_data = str(field_data).zfill(fields[field_num].field_length)
            message += field_data
        return message.encode("ascii")  # Mã hóa thành ASCII
# Định nghĩa các trường ISO 8583
class ISO8583Field:
    def __init__(self, field_number, field_type, field_length, data_type=None):
        self.field_number = field_number
        self.field_type = field_type  # N, A, B, S, Z
        self.field_length = field_length
        self.data_type = data_type  # Kiểu dữ liệu (nếu cần)

# Định nghĩa các trường cho JCB
fields = {
    "t": ISO8583Field(0, "B", 4, "MTI"),
    "2": ISO8583Field(2, "N", 19, "PAN"),
    "3": ISO8583Field(3, "N", 6, "Processing code"),
    "4": ISO8583Field(4, "N", 12, "Transaction amount"),
    "7": ISO8583Field(7, "N", 10, "Transmission date and time"),
    "11": ISO8583Field(11, "N", 6, "System trace audit number"),
    "12": ISO8583Field(12, "N", 6, "Time local transaction"),
    "13": ISO8583Field(13, "N", 4, "Date local transaction"),
    "18": ISO8583Field(18, "N", 4, "Merchant type"),
    "22": ISO8583Field(22, "N", 3, "POS entry mode"),
    "25": ISO8583Field(25, "N", 2, "POS condition code"),
    "35": ISO8583Field(35, "Z", 37, "Track 2 data"),
    "37": ISO8583Field(37, "N", 12, "Retrieval reference number"),
    "38": ISO8583Field(38, "N", 6, "Authorization identification response"),
    "41": ISO8583Field(41, "A", 8, "Terminal ID"),
    "42": ISO8583Field(42, "A", 15, "Merchant name"),
    "49": ISO8583Field(49, "N", 3, "Currency code"),
    "60": ISO8583Field(60, "S", 60, "Transaction description"),
    "61": ISO8583Field(61, "A", 250, "Additional data"),
    "62": ISO8583Field(62, "A", 128, "Additional information"),
    "63": ISO8583Field(63, "A", 100, "Card acceptor's terminal identification"),
    "90": ISO8583Field(90, "A", 42, "Network management information"),
    "95": ISO8583Field(95, "Z", 42, "Receipt number"),
    "98": ISO8583Field(98, "A", 25, "Authorization code"),
    "102": ISO8583Field(102, "A", 16, "Acquirer reference"),
    "128": ISO8583Field(128, "A", 8, "Message reason code"),
    # Thêm trường RDW vào fields 
    # "1": ISO8583Field(1, "B", 4, "RDW"), 
}


# Định nghĩa các loại giao dịch cho JCB
transaction_types = {
    "1240": {
        "0200": "Request authorization",
        "0210": "Authorization response",
        "0220": "Request settlement",
        "0221": "Settlement response",
        "0400": "Advice of transaction",
        "0420": "Advice response",
    },
    "1442": {
        "1410": "Chargeback request",
        "1420": "Chargeback response",
        "1430": "Chargeback retrieval request",
        "1440": "Chargeback retrieval response",
    },
    "1540": {
        "1500": "Acknowledgement request",
        "1501": "Acknowledgement response",
        "1510": "Settlement request",
        "1511": "Settlement response",
        "1520": "Advice of transaction",
        "1521": "Advice response",
    },
    "1644": {
        "1600": "Request system information",
        "1601": "System information response",
        "1620": "Request file transfer",
        "1621": "File transfer response",
    },
    "1740": {
        "1700": "Fee collection request",
        "1701": "Fee collection response",
        "1710": "Advice of transaction",
        "1711": "Advice response",
    },
}
def string_to_binary(input_string):
    binary_string = ''.join(format(int(char), '04b') for char in input_string)
    return binary_string

def calculate_rdw(message_length):
    # Chuyển đổi độ dài từ thập phân sang nhị phân và đảm bảo độ dài 24 bit
    rdw_binary = format(message_length, '024b')
    return rdw_binary

def lenOfIsoMessage(inputStr):
    message_length = len(inputStr.encode('ascii'))
    return message_length

def generate_rdw(message_length):
    """
    Tạo chuỗi RDW (Record Descriptor Word) cho ISO 8583.

    Args:
        message_length (int): Độ dài của message (không bao gồm RDW).

    Returns:
        bytes: Chuỗi RDW được mã hóa.
    """
    print(f' độ dài input: {message_length}')
    # _lenFormat = str(message_length).zfill(4)
    # print(f'format 4 ký tự: {_lenFormat}')
    # Chuyển đổi độ dài message sang dạng binary
    # binary_length = bin(_lenFormat)[2:].zfill(16)
    binary_length = calculate_rdw(message_length)
    # print()
    print(f'Binary: {binary_length}')
    # Chuyển đổi binary sang hexadecimal
    # hex_length = hex(int(binary_length, 2))[2:].zfill(4)
    hex_length = hex(int(binary_length, 2))[2:].zfill(8).upper()
    print(f'Hex: {hex_length}')
    # Chuyển đổi hexadecimal sang chuỗi bytes
    rdw = bytes.fromhex(hex_length)
    print(f'RDW: {rdw}')
    return rdw

# Ví dụ sử dụng
# message_length = 96  # Độ dài message
# rdw = generate_rdw(message_length)
# print(f"RDW (hexadecimal): {rdw.hex()}")  # Output: 0060
# print(f"RDW (binary): {binascii.b2a_base64(rdw).decode()}")  # Output: AA==

def generate_iso8583_batch_file(output_filename, transactions):
    """
    Tạo file batch ISO 8583.

    Args:
        output_filename (str): Tên file batch.
        transactions (list): Danh sách các giao dịch cần tạo batch.
    """
    output_filename = fullPath(output_filename)
    # for transaction in transactions:
    #     iso_string = generate_iso8583_string(transaction)
    # rdw = generate_rdw(len(iso_string))
    # transactions.insert(0,rdw)
    with open(output_filename, "wb") as f:
        for transaction in transactions:
            # Tạo chuỗi ISO 8583 cho mỗi giao dịch
            # iso_string, encoded = iso8583.encode(transaction, spec)
            iso_string = generate_iso8583_string(transaction)
            # Mã hóa chuỗi ISO 8583 bằng ASCII
            # iso_string = iso_string.encode("ascii")
            print(f'message ISO: {iso_string}')
            # lenIso = lenOfIsoMessage(iso_string)
            print(f'len ISO: {len(iso_string)}')
            rdw = generate_rdw(113)
            # Thêm RDW vào đầu message
            # iso_string = rdw.hex() + iso_string
            # print(rdw.hex())
            # f.write(rdw)
            # Ghi chuỗi ISO 8583 vào file batch
            # f.write(iso_string)
            # Thêm CRLF vào cuối thông điệp (bat cuoc cua JCB) kêt thúc dòng: CRLF là viết tắt của Carriage Return (CR) và Line Feed (LF).
            crlf = b'\x0d\x0a'
            # f.write(crlf)

def generate_iso8583_string(transaction):
    """
    Tạo chuỗi ISO 8583 từ dữ liệu giao dịch.

    Args:
        transaction (dict): Dữ liệu giao dịch.

    Returns:
        bytes: Chuỗi ISO 8583 được mã hóa.
    """

    iso_string = ""
    for field_number, field_data in transaction.items():
        field = fields.get(field_number)
        if field is None:
            continue

        
        # Xử lý dữ liệu theo kiểu trường
        if field.field_type == "N":
            field_data = str(field_data).zfill(field.field_length)
        elif field.field_type == "A":
            field_data = str(field_data).ljust(field.field_length)
        elif field.field_type == "B":
            field_data = str(field_data).zfill(field.field_length)
        elif field.field_type == "S":
            field_data = str(field_data).ljust(field.field_length)
        elif field.field_type == "Z":
            field_data = str(field_data).zfill(field.field_length)
        elif field.field_type == "LLVAR":
            field_data = str(field_data).zfill(field.field_length)
        elif field.field_type == "LLLVAR":
            field_data = str(field_data).zfill(field.field_length)

        iso_string += field_data

    # Mã hóa chuỗi ISO 8583
    return iso_string.encode("ascii")  # Mã hóa chuỗi ISO 8583

# Ví dụ sử dụng
transactions = [
    {
        "t": "0200",
        "2": "469672...8298",
        "3": "000000",
        "4": '000000010000',  # Transaction Amount
        "7": '0807123456',  # Transmission Date & Time
        "11": "114800",
        "12": "094516",
        "13": '0807',  # Date, Local Transaction
        "18": "0000",
        "22": "001",
        "25": "06",  # POS Condition Code (Approved)
        "35": "469672...8298",
        '37': '123456789012',  # Retrieval Reference Number
        "38": "000000",
        "41": "12345678",
        # "42": "Merchant Name",
        "49": "704",
        "60": "Payment Transaction",
        "61": "Additional Data",
        "62": "Additional Information",
        "63": "12345678",
        # "90": "Network Management Information",
        # "95": "12345678",
        # "98": "443227",  # Authorization code (AUTH)
        "102": "Acquirer Reference",
        # "128": "0000",
    },
    # ... thêm các giao dịch khác ...
]
def split_lines_crlf(text):
    # Tách dòng dựa trên CRLF (0x0d0a)
    lines = text.split(b'\r\n')
    return lines
def hex_to_bin(hex_string):
    # Chuyển đổi chuỗi hex sang chuỗi nhị phân
    bin_string = bin(int(hex_string, 16))[2:].zfill(len(hex_string) * 4)
    return bin_string

def parse_bitmap(bitmap_hex):
    # Chuyển đổi bitmap từ hex sang nhị phân
    bitmap_bin = hex_to_bin(bitmap_hex)

    # Tạo danh sách các trường dữ liệu có mặt trong thông điệp
    fields = [i + 1 for i, bit in enumerate(bitmap_bin) if bit == '1']

    return fields
def parse_iso8583_message(message):
    # Xác định MTI
    mti = message[:4]
    print(f"MTI: {mti}")

    # Xác định Bitmap
    primary_bitmap_hex = message[4:20]
    primary_bitmap_bin = bin(int(primary_bitmap_hex, 16))[2:].zfill(64)
    print(f"Primary Bitmap: {primary_bitmap_bin}")
    print(f'primary_bitmap_bin[0] = {primary_bitmap_bin[0]}')
    # Kiểm tra xem có secondary bitmap hay không
    if primary_bitmap_bin[0] == '1':
        secondary_bitmap_hex = message[20:36]
        secondary_bitmap_bin = bin(int(secondary_bitmap_hex, 16))[2:].zfill(64)
        print(f"Secondary Bitmap: {secondary_bitmap_bin}")
        bitmap_bin = primary_bitmap_bin + secondary_bitmap_bin
        data_elements_start = 36
    else:
        bitmap_bin = primary_bitmap_bin
        data_elements_start = 20

    # Xác định các trường dữ liệu
    data_elements = message[data_elements_start:]
    fields = {}
    field_positions = {
    1: 6, 7: 12, 11: 18, 12: 24, 13: 28, 32: 34, 39: 36, 41: 42, 42: 50, 49: 53, 52: 57, 53: 61, 62: 65
    }

    for field, end_pos in field_positions.items():
        start_pos = end_pos - (field_positions[field] - field_positions.get(field - 1, 0))
        fields[field] = data_elements[start_pos:end_pos]
        print(f"Field {field}: {fields[field]}")
# Ví dụ sử dụng
primary_bitmap = "8000010080010000"
secondary_bitmap = "0200000010000000"
msg = '68906160902032390102500224080100000160902000010000000106100000'
full_msg = '1644' + primary_bitmap + secondary_bitmap + msg
# primary_fields = parse_bitmap(primary_bitmap)
# secondary_fields = parse_bitmap(secondary_bitmap)

# print("Primary bitmap fields:", primary_fields)
# print("Secondary bitmap fields:", secondary_fields)
# encoded_raw = b'16448000010080010000020000001000000068906160902032390102500224080100000160902000010000000106100000'
# parse_iso8583_message(full_msg)
# try:
#     decoded, encoded = iso8583.decode(encoded_raw, custom_spec)
#     iso8583.pp(decoded, custom_spec)
#     iso8583.pp(encoded, custom_spec)
# except iso8583.DecodeError as e:
#     print(f"DecodeError: {e}")
# except Exception as e:
#     print(f"Unexpected error: {e}")
# Tạo file batch
output_filename = "jcb_batch_file"
# generate_iso8583_batch_file(output_filename, transactions)
# print(f"File batch ISO 8583 đã được tạo: {output_filename}")
fileRead = 'JCB_240911_002.txt'
# fileRead = 'JCBretail20240802100918.TXT'
fileRead = fileReadPath = os.path.join (reportPath, path, fileRead)
a = utils.readFile(fileReadPath,'rb')
# print(f'len of record {len(a)}')
# lines = split_lines_crlf(a)
# print(f'len of lines = {len(lines)}')
# for line in lines:
    
#     b= utils.convertBytesToAscii(line)
#     print(b)


# c= utils.convertBytesToUnicode(a)
# print(f'a = {a}')
# print(f'b = {b}')
# bb=a[:4] # ky tu dau
# bb= a[4:8] #R1644
# bb = a[4:86]
# bb = a[8:24]
# bb = a[24:86]
# bb = a[86:89]
# bb = a[89:89]
# bb = a[89:93]
# bb = a[182:185]
# xx = 'abcdefghgijqwert'
# lenOfMsg=a[:4]
# hexlenOfMsg = utils.convertBytesToHex(lenOfMsg) 
# lenOfMsg = utils.convertHexToInt(hexlenOfMsg) 
# print(f'len of Msg = {lenOfMsg}')

# HeaderMsg = a[4:86]
# print(f'Header Message (bytes) = {HeaderMsg}')

# mti = HeaderMsg[:4]
# print(f'mti = {mti}')
# primary_bm = HeaderMsg[4:12]
# hexRdw = utils.convertBytesToHex(primary_bm) 
# print(f'Primary BitMap= {parse_bitmap(hexRdw)}')

# secondaryBitmap = HeaderMsg[12:20]
# clearDrw = utils.convertBytesToAscii(secondaryBitmap)
# print(clearDrw)
# hexRdw = utils.convertBytesToHex(secondaryBitmap) 
# print(f'Secondary BitMap= {parse_bitmap(hexRdw)}')

# lenOfBit2 = HeaderMsg[20:22]
# clearDrw = utils.convertBytesToAscii(lenOfBit2)
# print(f'Len Of bit 2 (bytes) = {clearDrw}')
# hexRdw = utils.convertBytesToHex(lenOfBit2) 
# print(f'len of bit 2(hex) {hexRdw}')
# intRdw = utils.convertHexToInt(hexRdw)
# print(f'len of bit 2(int) {intRdw}')

# msg1240 = a[86:4]
lenOfMsg1240=a[86:90]
# clearDrw = utils.convertBytesToAscii(lenOfMsg1240)
hexlenOfMsg = utils.convertBytesToHex(lenOfMsg1240) 
# print(clearDrw)
lenOfMsg = utils.convertHexToInt(hexlenOfMsg) 
print(f'len of Msg = {lenOfMsg}')
msg1240 = a[90:lenOfMsg + 90]
# clearDrw = utils.convertBytesToAscii(msg1240)
# print(clearDrw)
lenOfMsg = 0
mti = msg1240[:4]
lenOfMsg += 4
print(f'mti = {mti}')
primary_bm = msg1240[4:12]
lenOfMsg += 8
hexRdw = utils.convertBytesToHex(primary_bm) 
print(f'Primary BitMap= {parse_bitmap(hexRdw)}')

secondaryBitmap = msg1240[12:20]
lenOfMsg += 8
# clearDrw = utils.convertBytesToAscii(secondaryBitmap)
# print(clearDrw)
hexRdw = utils.convertBytesToHex(secondaryBitmap) 
secondary_fields = parse_bitmap(hexRdw)
# Cộng thêm 64 cho các trường trong Secondary Bitmap
secondary_fields = [field + 64 for field in secondary_fields]
print(f'Secondary BitMap= {secondary_fields}')
startChar = 20
endChar = 22

def printData(bit:str, name:str, startChar:int, endChar:int):
    fieldEnscrypt = msg1240[startChar:endChar]
    clearDrw = utils.convertBytesToAscii(fieldEnscrypt)
    
    print(f'bit: {bit} | char len: {endChar - startChar}| clear text len={len(clearDrw)} | {name}: {clearDrw}')
    print('-----------------------------------------------------------')
    return endChar - startChar

# Figure 3-10-1-2-2: Interchange Message Layout page 195

lenOfMsg += printData(bit='#',name='Len Of bit 2 (bytes)',startChar=20, endChar=22)
lenOfMsg += printData(bit='2',name='PAN',startChar=22, endChar=38)
lenOfMsg += printData(bit='3',name='Pcode',startChar=38, endChar=44)
lenOfMsg += printData(bit='4',name='Amount',startChar=44, endChar=56)
lenOfMsg += printData(bit='12',name='Local transaction time (hhmmss)',startChar=56, endChar=68)
lenOfMsg += printData(bit='22',name='Point of service entry mode',startChar=68, endChar=80)
lenOfMsg += printData(bit='24',name='Function Code',startChar=80, endChar=83)
lenOfMsg += printData(bit='26',name='Card Acceptor Business Code (MCC)',startChar=83, endChar=87)
lenOfMsg += printData(bit='#',name='Length of Bit 31',startChar=87, endChar=89)
lenOfMsg += printData(bit='31',name='Acquirer Reference Data',startChar=89, endChar=112)
lenOfMsg += printData(bit='32',name='Acquiring Institution ID Code',startChar=112, endChar=120)
lenOfMsg += printData(bit='#',name='Length of Bit 33',startChar=120, endChar=122)
lenOfMsg += printData(bit='33',name='Forwarding Institution ID Code',startChar=122, endChar=128)
lenOfMsg += printData(bit='37',name='Retrieval reference number',startChar=128, endChar=140)
lenOfMsg += printData(bit='38',name='Card Acceptor ID Code',startChar=140, endChar=146)
lenOfMsg += printData(bit='40',name='Service restriction code',startChar=146, endChar=149)
lenOfMsg += printData(bit='41',name='Card acceptor terminal identification',startChar=149, endChar=157)
lenOfMsg += printData(bit='42',name='Card acceptor identification code',startChar=157, endChar=172)
lenOfMsg += printData(bit='#',name='Len of 43',startChar=172, endChar=174)
lenOfMsg += printData(bit='43',name='Card acceptor name/location',startChar=174, endChar=273)
lenOfMsg += printData(bit='#',name='len of 48',startChar=273, endChar=276)
lenOfMsg += printData(bit='48',name='Additional data (private)',startChar=276, endChar=287)
lenOfMsg += printData(bit='49',name='Currency code, transaction',startChar=287, endChar=290)
lenOfMsg += printData(bit='71',name='Message number',startChar=290, endChar=294)
lenOfMsg += printData(bit='94',name='Service indicator',startChar=294, endChar=301)

# print(lenOfMsg)
# print(msg1240[:301])
# encoded_raw = msg1240[:306]
# decoded, encoded = iso8583.decode(encoded_raw, spec)
# iso8583.pp(decoded, spec)
# iso8583.pp(encoded, spec)

# print(c)

# clearDrw = utils.convertBytesToAscii(c)
# hexRdw = utils.convertBytesToHex(c) 
# intRdw = utils.convertHexToInt(hexRdw) 


# print(f'clearDrw = {clearDrw}')
# print(f'hexRdw = {hexRdw}')

# print(f'intRdw = {intRdw}')
# try:
    
#     decoded, encoded = iso8583.decode(msg1240, spec)
#     iso8583.pp(decoded, spec)
#     iso8583.pp(encoded, spec)
# except iso8583.DecodeError as e:
#     print(f"DecodeError: {e}")
# except Exception as e:
#     print(f"Unexpected error: {e}")

# print(bb)
# print(f'c = {c}')
# t = '68906160902032390102500224080100000160902000010000000106100000'
# rdw = generate_rdw(len(t))
# clearDrw = utils.convertBytesToAscii(rdw)
# hexRdw = utils.convertBytesToHex(rdw)    
    
# print(f'rdw = {rdw}')




# Ví dụ message mẫu cho JCB
# Yêu cầu xác thực
message_auth = ISO8583Message(
    "0200",
    {
        2: "469672...8298",
        3: "000000",
        4: "28650000",
        7: "20210524094516",
        11: "114800",
        12: "094516",
        13: "20210524",
        18: "0000",
        22: "001",
        25: "00",
        35: "469672...8298",
        37: "114800",
        38: "000000",
        41: "12345678",
        42: "Merchant Name",
        49: "704",
        60: "Payment Transaction",
        61: "Additional Data",
        62: "Additional Information",
        63: "12345678",
        90: "Network Management Information",
        95: "12345678",
        98: "443227",  # Authorization code (AUTH)
        102: "Acquirer Reference",
        128: "0000",
    }
)

# Phản hồi xác thực
message_auth_response = ISO8583Message(
    "0210",
    {
        38: "000000",  # Mã xác thực
        98: "443227",  # Mã xác thực
    }
)
# In chuỗi ISO 8583 được mã hóa
# print(message_auth.get_message_string().hex())
# print(message_auth_response.get_message_string().hex())

"""
Giải thích code:
ISO8583Field: Lớp này giúp định nghĩa thông tin của mỗi trường ISO 8583, bao gồm:
field_number: Số hiệu trường.
field_type: Kiểu trường (N: Số, A: Chuỗi, B: Binary, S: Chuỗi có độ dài cố định, Z: Số có độ dài cố định).
field_length: Độ dài trường.
data_type: Kiểu dữ liệu bổ sung (nếu cần, ví dụ: AUTH cho mã xác thực).
fields: Dictionary lưu trữ thông tin về các trường ISO 8583 được sử dụng cho JCB.
generate_iso8583_batch_file: Hàm này tạo file batch ISO 8583 từ danh sách các giao dịch.
generate_iso8583_string: Hàm này tạo chuỗi ISO 8583 từ dữ liệu giao dịch.
transactions: Danh sách các giao dịch mẫu.
Cách sử dụng:
Sửa đổi transactions để thêm các giao dịch cần tạo batch.
Sửa đổi output_filename để đặt tên cho file batch.
Chạy code để tạo file batch ISO 8583.
Lưu ý:
Code này giả sử rằng định dạng của các giao dịch trùng khớp với định dạng được sử dụng trong các trường fields.
Kiểm tra kỹ thông tin được sử dụng trong file batch ISO 8583. Hãy đảm bảo rằng định dạng của các trường phù hợp với yêu cầu của JCB.
Hy vọng code này giúp bạn!

"""


"""
Mẫu message cho các MIT (Message Type Indicator) của ISO 8583 (JCB):
1240: Financial Messages
Mục đích: Xử lý các giao dịch tài chính.
Ví dụ:
0200: Request authorization (Yêu cầu xác thực).
0210: Authorization response (Phản hồi xác thực).
0220: Request settlement (Yêu cầu thanh toán).
0221: Settlement response (Phản hồi thanh toán).
0400: Advice of transaction (Thông báo giao dịch).
0420: Advice response (Phản hồi thông báo).
1442: Chargeback Messages
Mục đích: Xử lý các yêu cầu hoàn tiền (chargeback).
Ví dụ:
1410: Chargeback request (Yêu cầu hoàn tiền).
1420: Chargeback response (Phản hồi hoàn tiền).
1430: Chargeback retrieval request (Yêu cầu thu hồi hoàn tiền).
1440: Chargeback retrieval response (Phản hồi thu hồi hoàn tiền).
1540: Acknowledgement/Settlement Related Messages
Mục đích: Xử lý xác nhận và thanh toán.
Ví dụ:
1500: Acknowledgement request (Yêu cầu xác nhận).
1501: Acknowledgement response (Phản hồi xác nhận).
1510: Settlement request (Yêu cầu thanh toán).
1511: Settlement response (Phản hồi thanh toán).
1520: Advice of transaction (Thông báo giao dịch).
1521: Advice response (Phản hồi thông báo).
1644: Administrative Messages
Mục đích: Xử lý các thông tin quản trị.
Ví dụ:
1600: Request system information (Yêu cầu thông tin hệ thống).
1601: System information response (Phản hồi thông tin hệ thống).
1620: Request file transfer (Yêu cầu chuyển file).
1621: File transfer response (Phản hồi chuyển file).
1740: Fee Collection Messages
Mục đích: Xử lý các yêu cầu thu phí.
Ví dụ:
1700: Fee collection request (Yêu cầu thu phí).
1701: Fee collection response (Phản hồi thu phí).
1710: Advice of transaction (Thông báo giao dịch).
1711: Advice response (Phản hồi thông báo).
"""

# import pyiso8583