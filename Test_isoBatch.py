# import iso8583
import binascii
import configparser
import os
import sys
# from iso8583.specs import default_ascii as spec
from datetime import datetime

# import iso8583.specs
from core.ISO8583Message.JCBbitmap import JCBfields
from core.ISO8583Message.JCBParser import JCBParser
from core.ISO8583Message.JCBWriter import JCBWriter
from core import Utils as utils


config = configparser.ConfigParser()


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
    
def hex_to_bin(hex_string):
    # Chuyển đổi chuỗi hex sang chuỗi nhị phân
    print(f'mmmm = {len(hex_string)}')
    bin_string = bin(int(hex_string, 16))[2:].zfill(len(hex_string) * 4)
    return bin_string

def parse_bitmap(bitmap_hex):
    # Chuyển đổi bitmap từ hex sang nhị phân
    bitmap_bin = hex_to_bin(bitmap_hex)

    # Tạo danh sách các trường dữ liệu có mặt trong thông điệp
    fields = [i + 1 for i, bit in enumerate(bitmap_bin) if bit == '1']

    return fields







fileRead = 'JCB_240911_002.txt'
# fileRead = 'JCBretail20240802100918.TXT'
# fileRead = 'JCB_TEST_1240.txt'
fileRead = fileReadPath = os.path.join (reportPath, path, fileRead)
a = utils.readFile(fileReadPath,'rb')

# msg1240 = a[:400]
# a =  b'\x00\x00\x00\xf21240\xd0\x10\x05C\x84a\x80\x00\x02\x00\x00\x04\x00\x00\x00\x0016356012345678901200000100000014070112153529010125400020053112371234560702000000000001061234560612345600000112345678901234564AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA011300200441004100000000206123456'
lenOfMsg = len(a)
# start = 0
parsor = JCBParser()
iso_dict = parsor.iso_decode(a)
# # print(iso_dict)
parsor.iso_dump(iso_dict,True)
# 
# writer = JCBWriter()

index = 0
header = a[index:4]

iso = {
    "2" : "3560123456789012",
    "3" : "000000",
    "4" : "000001000000",
    "12": "140701121535",
    "22": "290101254000",
    "24": "200",
    "26": "5311",
    "31": "71234560702000000000001",
    "32": "123456",
    "33": "123456",
    "38": "000001",
    "42": "123456789012345",
    "43": "YONGSAN∆DEPARTMENT∆STORE∆100-1234∆HANGANGNO∆3-GA,∆∆…SEOUL∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆KORKOR",
    "48": "30020044100",
    "49": "410",
    "71": "00000002",
    "94": "123456"

}
iso_string = ""
field = JCBfields.get("31")
a = str(iso["31"].zfill(field.field_length))
len_a = len(a)
print(a)
print(len_a)

# for field_number, field_data in iso.items():
#     field = JCBfields.get(field_number)
#     if field is None:
#         continue

#     # Xử lý dữ liệu theo kiểu trường
#     if field.field_type == "N":
#         field_data = str(field_data).zfill(field.field_length)
#     elif field.field_type == "A":
#         field_data = str(field_data).ljust(field.field_length)
#     elif field.field_type == "B":
#         field_data = str(field_data).zfill(field.field_length)
#     elif field.field_type == "S":
#         field_data = str(field_data).ljust(field.field_length)
#     elif field.field_type == "Z":
#         field_data = str(field_data).zfill(field.field_length)
#     elif field.field_type == "LL":
#         field_data = str(field_data).zfill(field.field_length)
#     elif field.field_type == "LLL":
#         field_data = str(field_data).zfill(field.field_length)

#     iso_string += field_data

# print(iso_string)

# print(iso_string.encode("shift_jis"))

# print(f'header {header}, { int.from_bytes(header, byteorder='big')}')
# print(f'header {header}')
# index += 4
# mti = a[index:index+4]
# print(f'mti {mti} , {mti.decode("ascii", errors="ignore")}')
# index += 4
# bitmap = a[index:index + 16]
# print(f'bitmap {bitmap}')
# index += 16
# str_bitmap = bitmap.decode("ascii", errors="ignore")
# print(f'string {str_bitmap}')
# b_bitmap =  bytes.fromhex(bitmap)
# print(f'bitmap= {b_bitmap}, len {len(b_bitmap)}')

# b = writer.write_iso8583_header(a)
# b = writer.generate_rdw(96,4)

# hex_bitmap = "F0100543846184000200000400000000"
# byte_bitmap = bytes.fromhex(hex_bitmap)

# print(byte_bitmap)
# print(len(byte_bitmap))



# utils.writeFile(b,fileRead,"wb")


# from iso8583 import iso8583
# from iso8583.specs import default_ascii as spec

# # Chuỗi thông điệp ISO8583 mẫu với PDE ở bit 48
# iso_message = b'0200400000000000000010123456789000000048PDE_DATA_HERE'

# # Giải mã thông điệp
# decoded, encoded = iso8583.decode(iso_message, spec)

# # In kết quả giải mã
# print("Decoded message:")
# for key, value in decoded.items():
#     print(f"{key}: {value}")

# # Lấy PDE từ bit 48
# pde_data = decoded.get('48', 'No PDE data found')
# print("PDE Data:", pde_data)

# from ebcdic import EBCDICCodec

# # Bảng mã EBCDIC Latin 9 (CPGID: 00924)
# latin9_codec = EBCDICCodec('cp00924')

# # Bảng mã EBCDIC USA/CANADA – CECP (CPGID: 00037)
# us_canada_codec = EBCDICCodec('cp037')

def encode_to_ebcdic(data, codec):
    """
    Mã hóa chuỗi ASCII sang EBCDIC.

    :param data: Chuỗi ASCII cần mã hóa.
    :param codec: Bảng mã EBCDIC sử dụng để mã hóa.
    :return: Chuỗi EBCDIC đã mã hóa.
    """
    return codec.encode(data)

def decode_from_ebcdic(data, codec):
    """
    Giải mã chuỗi EBCDIC sang ASCII.

    :param data: Chuỗi EBCDIC cần giải mã.
    :param codec: Bảng mã EBCDIC sử dụng để giải mã.
    :return: Chuỗi ASCII đã giải mã.
    """
    return codec.decode(data)

# Ví dụ sử dụng
# ascii_string = "Hello, JCB!"
# ebcdic_encoded = encode_to_ebcdic(ascii_string, latin9_codec)
# print("EBCDIC Encoded (Latin 9):", ebcdic_encoded)

# ascii_decoded = decode_from_ebcdic(ebcdic_encoded, latin9_codec)
# print("ASCII Decoded (Latin 9):", ascii_decoded)

# # Sử dụng bảng mã USA/CANADA – CECP
# ebcdic_encoded_us = encode_to_ebcdic(ascii_string, us_canada_codec)
# print("EBCDIC Encoded (USA/CANADA):", ebcdic_encoded_us)

# ascii_decoded_us = decode_from_ebcdic(ebcdic_encoded_us, us_canada_codec)
# print("ASCII Decoded (USA/CANADA):", ascii_decoded_us)

def convert_date_to_binary(date_str):
    """
    Chuyển đổi chuỗi ngày tháng (YYMMDD) thành dạng nhị phân theo tiêu chuẩn JCB.

    :param date_str: Chuỗi ngày tháng (YYMMDD).
    :return: Chuỗi nhị phân.
    """
    if len(date_str) != 6:
        raise ValueError("Chuỗi ngày tháng phải có độ dài 6 ký tự (YYMMDD).")

    binary_str = ""
    for char in date_str:
        # Chuyển đổi từng ký tự thành nhị phân 4 bit
        binary_char = format(int(char), '04b')
        binary_str += binary_char

    return binary_str

# Ví dụ sử dụng
# date_str = "140702"  # Ngày 2 tháng 7 năm 2014
# binary_date = convert_date_to_binary(date_str)
# print("Chuỗi nhị phân:", binary_date)

# python_path = sys.executable
# print("Đường dẫn của Python:", python_path)

# import pyiso8583

# import sys



# import sys
# print(sys.prefix)
# print(sys.path)
# print(sys.executable)

