import iso8583
import os
import configparser
from iso8583.specs import default_ascii as spec
from datetime import datetime
from utilities import Utils as utils

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

def create_iso8583_message():
# Tạo thông điệp ISO 8583
    # message = {
    #     't': '0200',  # Message Type Indicator
    #     '2': '1234567890123456',  # Primary Account Number (PAN)
    #     '3': '000000',  # Processing Code
    #     '4': '000000010000',  # Transaction Amount
    #     '7': '0807123456',  # Transmission Date & Time
    #     '11': '123456',  # Systems Trace Audit Number (STAN)
    #     '12': '123456',  # Time, Local Transaction
    #     '13': '0807',  # Date, Local Transaction
    #     '37': '123456789012',  # Retrieval Reference Number
    #     '41': '12345678',  # Card Acceptor Terminal Identification
    #     '49': '840',  # Currency Code, Transaction
    #     }
    # Tạo thông điệp ISO 8583
    message = {
    't': '0200',  # Message Type Indicator
    '2': '1234567890123456',  # Primary Account Number (PAN)
    '3': '000000',  # Processing Code
    '4': '000000010000',  # Transaction Amount
    '7': '0807123456',  # Transmission Date & Time
    '11': '123456',  # Systems Trace Audit Number (STAN)
    '12': '123456',  # Time, Local Transaction
    '13': '0807',  # Date, Local Transaction
    '37': '123456789012',  # Retrieval Reference Number
    '41': '12345678',  # Card Acceptor Terminal Identification
    '49': '840',  # Currency Code, Transaction
    }

    # Mã hóa thông điệp ISO 8583
    encoded_message, encoded = iso8583.encode(message, spec)
    print(encoded_message)
    # iso8583.pp(encoded_message, spec)
    # iso8583.pp(encoded, spec)
    return encoded_message

def write_batch_file(filename, messages):
    __fileName = fullPath(filename) + '.' + 'data'
    with open(__fileName, 'wb') as f:
        for message in messages:
            f.write(message + b'\n')

if __name__ == "__main__":
# Tạo danh sách các thông điệp ISO 8583
    # messages = [create_iso8583_message() for _ in range(10)]  # Tạo 10 thông điệp mẫu

# Ghi các thông điệp vào tệp batch
    # write_batch_file('jcb_batch_file', messages)

    encoded_raw = b'8000010080010000020000001000'
    # encoded_raw = b'1240\xf0\x10\x05C\x8d\xe1\x80\x00\x02\x00\x00\x04\x00\x00\x00\x00163564187699530512010000000004000000240731084904511401U130062006011237160902080143085565287506160902061609024213084194735768572010008500105790261205    99VCCB - PGD CAM RANH      409 Duong 3 Thang 4, Cam Linh, Cam Ranh      CAM RANH     085       704VNM011300200470407040000000'
    decoded, encoded = iso8583.decode(encoded_raw, spec)
    iso8583.pp(decoded, spec)
    iso8583.pp(encoded, spec)

    print("Batch file created successfully.")
