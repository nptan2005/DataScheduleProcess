import copy
from decimal import Decimal

def bytes_to_hex(data:bytes)-> str:
    return data.hex().upper()

def bytes_to_int(data:bytes) -> int:
    return  int.from_bytes(data, byteorder='big')

def bytes_to_accii(data:bytes, decodeType:str = 'ascii') -> str:
    """
    decodeType:str = 'ascii'
    decodeType:str = 'latin-1'
    decodeType:str = 'utf-8'
    """
    return data.decode(decodeType).strip()

def bytes_to_binary(data:bytes, fill_len:int=64) -> str:
    # bin(int(data.hex().upper(), 16))[2:].zfill(64) 
    return bin(hex_to_int(bytes_to_hex(data)))[2:].zfill(fill_len) 

def hex_to_bytes(data:str)-> bytes:
    return bytes.fromhex(data)

def hex_to_int(data:str)-> int:
    return int(data, 16)

def hex_to_ascii(hex_str:str) -> str:
    bytes_object = bytes.fromhex(hex_str)
    ascii_str = bytes_object.decode("ascii", errors="ignore")
    return ascii_str

def string_to_binary(input_string):
    binary_string = ''.join(format(int(char), '04b') for char in input_string)
    return binary_string




def lenOfIsoMessage(inputStr):
    message_length = len(inputStr.encode('ascii'))
    return message_length

def is_byte(data):
    return isinstance(data, bytes)

def is_hex(data):
    try:
        int(data, 16)
        return True
    except ValueError:
        return False
def is_empty(data):
    if data is None:
        return True
    if len(data) == 0:
        return True
    
def dict_has_data(d: dict) -> bool:
    return any(d.values())

def decodeTagValue(raw_data, valueType, tag = None):
    if valueType == "H":
        if is_hex(raw_data):
            return raw_data  # Keep as hex
        elif is_byte(raw_data):
            return bytes_to_hex(raw_data) 
        else:
            return raw_data
    elif valueType == "N":
        if is_hex(raw_data):
            return hex_to_int(raw_data)  # Convert hex to integer
        elif is_byte(raw_data):
            return bytes_to_int(raw_data)
        else:
            return raw_data
    elif valueType == "M":
        if is_hex(raw_data):
            return float(hex_to_int(raw_data))   # Assume money is stored in cents need /100. else keep org values
        elif is_byte(raw_data):
            return float(bytes_to_int(raw_data))
        else:
            return raw_data
    elif valueType == "A": # Convert hex to ASCII string
        if is_hex(raw_data):
            return hex_to_ascii(raw_data)
        elif is_byte:
            return hex_to_ascii(bytes_to_hex(raw_data))
    elif valueType == "BCD":
        return raw_data.hex()
        # BCD length
        # elif field_spec["len_enc"] == "bcd":
        #     try:
        #         enc_field_len = int(s[idx : idx + len_type].hex(), 10)
    elif  valueType == "TVR" and tag == "9505":
        tvr = TVRData(raw_data)
        return tvr.parse()
    else:
        return raw_data  # Default: keep raw data
    
def get_currency_symbol(currency_code):
    # Chuyển đổi mã tiền tệ thành ký hiệu
    if currency_code == 840:
        return "USD"
    elif currency_code == 978:
        return "EUR"
    elif currency_code == 704:
        return "VND"
    else:
        return "Unknown Currency"
    

def format_amount(hex_amount, hex_currency_code):
    # Chuyển đổi hex của số tiền (9F02)
    amount = Decimal(int(hex_amount, 16)) / Decimal(100)
        
    # Chuyển đổi mã tiền tệ từ hex (5F2A)
    currency_code = int(hex_currency_code, 16)

    # Lấy ký hiệu tiền tệ dựa trên mã ISO 4217
    currency = get_currency_symbol(currency_code)

    return f"{currency} {amount:.2f}"

class ISO8583Error(ValueError):
    def __init__(self, bit, length, position, message="ISO 8583 Error"):
        errmsg = f"{message}: bit {bit}, position {position}"
        ValueError.__init__(self, errmsg)
        self.bit = bit
        self.length = length
        self.position = position

    def __str__(self):
        return f"{self.args[0]}: Bit {self.bit}, Length {self.length}, Position {self.position}"
# end class ISO8583Error

"""
•  h: Header - Thường chứa thông tin tiêu đề của thông điệp.

•  t: MTI (Message Type Indicator) - Chỉ báo loại thông điệp, xác định loại giao dịch.

•  p: Primary Bitmap - Bitmap chính, xác định các trường dữ liệu có mặt trong thông điệp.

•  s: Secondary Bitmap - Bitmap phụ, xác định các trường dữ liệu bổ sung có mặt trong thông điệp.
"""
class ISO8583Field:
    def __init__(self, field_number:int, field_type:str, field_length:int, data_type:str=None, prefix:str=None):
        """
        field_number: bit
        field_type: kiểu dữ liệu
        field_length: max len của field
        data_type: Diễn giải field
        field_type: N, A, B, S, Z
            •  N: Numeric - Chỉ chứa các ký tự số (0-9).
            •  A: Alphanumeric - Chứa các ký tự chữ và số (A-Z, a-z, 0-9).
            •  B: Binary - Chứa dữ liệu nhị phân.
            •  S: Special - Chứa các ký tự đặc biệt
            •  Z: Track Data - Chứa dữ liệu track (thường được sử dụng cho dữ liệu thẻ từ).
        field_length: max len
        data_type: description of bit
        prefix: # L, LL, LLL
            •  define 1 len
            •  define 2 len
            •  define 3 len
        """
        self.field_number = field_number
        self.field_type = field_type  # N, A, B, S, Z
        self.field_length = field_length
        self.data_type = data_type  # Kiểu dữ liệu (nếu cần)
        self.prefix = prefix  #L, LL, LLL
        self._encodeValue = None
        self._decodeValue = None

    @property
    def encodeValue(self):
        return self._encodeValue
    
    @encodeValue.setter
    def encodeValue(self,value):
        self._encodeValue = value

    @property
    def decodeValue(self):
        return self._decodeValue
    
    @decodeValue.setter
    def decodeValue(self, value):
        self._decodeValue = value

    def __deepcopy__(self, memo):
        # Tạo một bản sao mới của đối tượng
        deepCopyCls = ISO8583Field(
        self.field_number,
        self.field_type,
        self.field_length,
        self.data_type,
        self.prefix
        )
        deepCopyCls.encodeValue = copy.deepcopy(self.encodeValue, memo)
        deepCopyCls.decodeValue = copy.deepcopy(self.decodeValue, memo)
        return deepCopyCls
# ISO8583Field



class TLVField:
    def __init__(self, bit, tag, length, description, valueType, prefix=None, hexLength=None, value=None):
        self.bit = bit
        self.tag = tag
        self.length = length
        self.description = description
        self.valueType = valueType  # H: Hex, N: Number, M: Money, A: ASCII, etc.
        self.prefix = prefix  # Prefix if applicable
        self.hexLength = hexLength  # If length is hex-encoded (e.g., LLVAR)
        self.value = value  # The actual value stored
    
    def parse_value(self, raw_data):
        return decodeTagValue(raw_data,self.valueType,self.tag)
        
    def parse_amount(self,hex_amount, hex_currency_code):
        # Chuyển đổi hex của số tiền (9F02)
        amount = Decimal(int(hex_amount, 16)) / Decimal(100)
        
        # Chuyển đổi mã tiền tệ từ hex (5F2A)
        currency_code = int(hex_currency_code, 16)

        # Lấy ký hiệu tiền tệ dựa trên mã ISO 4217
        currency = get_currency_symbol(currency_code)

        return f"{currency} {amount:.2f}"


    def __repr__(self):
        return f"TLVField({self.bit}, {self.tag}, {self.length}, {self.description}, {self.valueType})"


# end class TLVField: 
       
class TVRData:
    def __init__(self, hex_tvr):
        """
        Tag: 9505
        TVR (Terminal Verification Results) chứa kết quả các kiểm tra bảo mật và xác thực được thực hiện bởi thiết bị terminal khi xử lý giao dịch thẻ. TVR là một chuỗi 5 bytes (40 bits), trong đó mỗi bit biểu diễn một trạng thái kiểm tra cụ thể (như xác thực offline, xác minh PIN, kiểm tra mã số quốc gia).

            Mô tả bit flag trong TVR (theo EMV):

                •	Byte 1:
                    •	Bit 8: Offline Data Authentication Was Not Performed
                    •	Bit 7: SDA Failed
                    •	Bit 6: ICC Data Missing
                    •	Bit 5: Card Appears on Terminal Exception File
                    •	Bit 4: DDA Failed
                    •	Bit 3: CDA Failed
                    •	Bit 2: RFU (Reserved for Future Use)
                    •	Bit 1: RFU
                •	Byte 2:
                    •	Bit 8: ICC and Terminal Have Different Application Versions
                    •	Bit 7: Expired Application
                    •	Bit 6: Application Not Yet Effective
                    •	Bit 5: Requested Service Not Allowed for Card Product
                    •	Bit 4: New Card
                •	Byte 3:
                    •	Bit 8: Cardholder Verification Was Not Successful
                    •	Bit 7: Unrecognised CVM
                    •	Bit 6: PIN Try Limit Exceeded
                    •	Bit 5: PIN Entry Required and PIN Pad Not Present or Not Working
                    •	Bit 4: PIN Entry Required, PIN Pad Present, But PIN Was Not Entered
                    •	Bit 3: Online PIN Entered
                	•	Bit 2-1: RFU
                •	Byte 4:
                    •	Bit 8: Transaction Exceeds Floor Limit
                    •	Bit 7: Lower Consecutive Offline Limit Exceeded
                    •	Bit 6: Upper Consecutive Offline Limit Exceeded
                    •	Bit 5: Transaction Selected Randomly for Online Processing
                    •	Bit 4: Merchant Forced Transaction Online
                •	Byte 5:
                    •	Bit 8: Default TDOL Used
                    •	Bit 7: Issuer Authentication Failed
                    •	Bit 6: Script Processing Failed Before Final GENERATE AC
                    •	Bit 5: Script Processing Failed After Final GENERATE AC
        """
        # Chuyển TVR từ hex sang nhị phân
        if not hex_tvr:
            raise ValueError("hex_tvr is empty")
        try:
            self.tvr_bin = bin(int(hex_tvr, 16))[2:].zfill(40)  # 5 bytes = 40 bits
        except ValueError as e:
            raise ValueError(f"Invalid hex value: {hex_tvr}") from e
       
    
    def parse(self):
        # Mapping chi tiết từng bit trong TVR
        parsed_tvr = {
            # Byte 1 (Bits 1-8)
            "Offline Data Authentication Not Performed": self.tvr_bin[0],
            "SDA Failed": self.tvr_bin[1],
            "ICC Data Missing": self.tvr_bin[2],
            "Card on Terminal Exception File": self.tvr_bin[3],
            "DDA Failed": self.tvr_bin[4],
            "CDA Failed": self.tvr_bin[5],
            "RFU Byte 1 Bit 2": self.tvr_bin[6],
            "RFU Byte 1 Bit 1": self.tvr_bin[7],
            # Byte 2 (Bits 9-16)
            "ICC and Terminal Different Application Versions": self.tvr_bin[8],
            "Expired Application": self.tvr_bin[9],
            "Application Not Yet Effective": self.tvr_bin[10],
            "Service Not Allowed for Card Product": self.tvr_bin[11],
            "New Card": self.tvr_bin[12],
            "RFU Byte 2 Bit 3": self.tvr_bin[13],
            "RFU Byte 2 Bit 2": self.tvr_bin[14],
            "RFU Byte 2 Bit 1": self.tvr_bin[15],
            # Byte 3 (Bits 17-24)
            "Cardholder Verification Not Successful": self.tvr_bin[16],
            "Unrecognized CVM": self.tvr_bin[17],
            "PIN Try Limit Exceeded": self.tvr_bin[18],
            "PIN Entry Required and PIN Pad Not Present": self.tvr_bin[19],
            "PIN Pad Present But PIN Not Entered": self.tvr_bin[20],
            "Online PIN Entered": self.tvr_bin[21],
            "RFU Byte 3 Bit 2": self.tvr_bin[22],
            "RFU Byte 3 Bit 1": self.tvr_bin[23],
            # Byte 4 (Bits 25-32)
            "Transaction Exceeds Floor Limit": self.tvr_bin[24],
            "Lower Consecutive Offline Limit Exceeded": self.tvr_bin[25],
            "Upper Consecutive Offline Limit Exceeded": self.tvr_bin[26],
            "Transaction Randomly Selected for Online": self.tvr_bin[27],
            "Merchant Forced Transaction Online": self.tvr_bin[28],
            "RFU Byte 4 Bit 3": self.tvr_bin[29],
            "RFU Byte 4 Bit 2": self.tvr_bin[30],
            "RFU Byte 4 Bit 1": self.tvr_bin[31],
            # Byte 5 (Bits 33-40)
            "Default TDOL Used": self.tvr_bin[32],
            "Issuer Authentication Failed": self.tvr_bin[33],
            "Script Processing Failed Before Final AC": self.tvr_bin[34],
            "Script Processing Failed After Final AC": self.tvr_bin[35],
            "RFU Byte 5 Bit 4": self.tvr_bin[36],
            "RFU Byte 5 Bit 3": self.tvr_bin[37],
            "RFU Byte 5 Bit 2": self.tvr_bin[38],
            "RFU Byte 5 Bit 1": self.tvr_bin[39],
        }
        return parsed_tvr
# end class TVR

class CustomField:
    def __init__(self, bit, tag, length, description, valueType):
        """
        Format:
        tag: s1,s2,s3,s4,s5
        length:
        description
        valueType
        value
        """
        self.bit = bit
        self.tag = tag
        self.length = length
        self.description = description
        self.valueType = valueType  # H: Hex, N: Number, M: Money, A: ASCII, etc.

    
    def parse_value(self, raw_data):
        if self.bit == 43 and self.valueType == "A":
            return raw_data.decode('ascii').strip() #loai khoang trang
        return decodeTagValue(raw_data,self.valueType,self.tag)
# CustomField





# Định nghĩa các trường cho ISO8583
iso8583fields = {
"t": ISO8583Field(0, "B", 4, "MTI"),
"1": ISO8583Field(1, "B", 16, "Bitmap"),
"2": ISO8583Field(2, "N", 19, "Primary account number (PAN)", "LL"),
"3": ISO8583Field(3, "N", 6, "Processing code"),
"4": ISO8583Field(4, "N", 12, "Transaction amount"),
"5": ISO8583Field(5, "N", 12, "Amount, settlement"),
"6": ISO8583Field(6, "N", 12, "Amount, cardholder billing"),
"7": ISO8583Field(7, "N", 10, "Transmission date and time"),
"8": ISO8583Field(8, "N", 8, "Amount, cardholder billing fee"),
"9": ISO8583Field(9, "N", 8, "Conversion rate, settlement"),
"10": ISO8583Field(10, "N", 8, "Conversion rate, cardholder billing"),
"11": ISO8583Field(11, "N", 6, "System trace audit number"),
"12": ISO8583Field(12, "N", 12, "Time, local transaction"),
"13": ISO8583Field(13, "N", 4, "Date, local transaction"),
"14": ISO8583Field(14, "N", 4, "Date, expiration"),
"15": ISO8583Field(15, "N", 4, "Date, settlement"),
"16": ISO8583Field(16, "N", 4, "Date, conversion"),
"17": ISO8583Field(17, "N", 4, "Date, capture"),
"18": ISO8583Field(18, "N", 4, "Merchant type"),
"19": ISO8583Field(19, "N", 3, "Acquiring institution country code"),
"20": ISO8583Field(20, "N", 3, "PAN extended country code"),
"21": ISO8583Field(21, "N", 3, "Forwarding institution country code"),
"22": ISO8583Field(22, "N", 12, "Point of service entry mode"),
"23": ISO8583Field(23, "N", 3, "Application PAN sequence number"),
"24": ISO8583Field(24, "N", 3, "Function code"),
"25": ISO8583Field(25, "N", 2, "Point of service condition code"),
"26": ISO8583Field(26, "N", 2, "Point of service capture code"),
"27": ISO8583Field(27, "N", 1, "Authorizing identification response length"),
"28": ISO8583Field(28, "A", 8, "Amount, transaction fee"),
"29": ISO8583Field(29, "A", 8, "Amount, settlement fee"),
"30": ISO8583Field(30, "A", 8, "Amount, transaction processing fee"),
"31": ISO8583Field(31, "A", 8, "Amount, settlement processing fee"),
"32": ISO8583Field(32, "N", 11, "Acquiring institution identification code", "LL"),
"33": ISO8583Field(33, "N", 11, "Forwarding institution identification code", "LL"),
"34": ISO8583Field(34, "A", 28, "Primary account number, extended", "LL"),
"35": ISO8583Field(35, "Z", 37, "Track 2 data", "LL"),
"36": ISO8583Field(36, "Z", 104, "Track 3 data", "LLL"),
"37": ISO8583Field(37, "A", 12, "Retrieval reference number"),
"38": ISO8583Field(38, "A", 6, "Authorization identification response"),
"39": ISO8583Field(39, "A", 2, "Response code"),
"40": ISO8583Field(40, "A", 3, "Service restriction code"),
"41": ISO8583Field(41, "A", 8, "Card acceptor terminal identification"),
"42": ISO8583Field(42, "A", 15, "Card acceptor identification code"),
"43": ISO8583Field(43, "A", 40, "Card acceptor name/location"),
"44": ISO8583Field(44, "A", 25, "Additional response data", "LL"),
"45": ISO8583Field(45, "A", 76, "Track 1 data", "LL"),
"46": ISO8583Field(46, "A", 999, "Additional data - ISO", "LLL"),
"47": ISO8583Field(47, "A", 999, "Additional data - national", "LLL"),
"48": ISO8583Field(48, "A", 999, "Additional data - private", "LLL"),
"49": ISO8583Field(49, "N", 3, "Currency code, transaction"),
"50": ISO8583Field(50, "N", 3, "Currency code, settlement"),
"51": ISO8583Field(51, "N", 3, "Currency code, cardholder billing"),
"52": ISO8583Field(52, "B", 16, "Personal identification number data"),
"53": ISO8583Field(53, "N", 18, "Security related control information"),
"54": ISO8583Field(54, "A", 120, "Additional amounts", "LLL"),
"55": ISO8583Field(55, "B", 255, "ICC data – EMV having multiple tags", "LLL"),
"56": ISO8583Field(56, "A", 999, "Reserved ISO", "LLL"),
"57": ISO8583Field(57, "A", 999, "Reserved national", "LLL"),
"58": ISO8583Field(58, "A", 999, "Reserved national", "LLL"),
"59": ISO8583Field(59, "A", 999, "Reserved national", "LLL"),
"60": ISO8583Field(60, "A", 999, "Reserved national", "LLL"),
"61": ISO8583Field(61, "A", 999, "Reserved private", "LLL"),
"62": ISO8583Field(62, "A", 999, "Reserved private", "LLL"),
"63": ISO8583Field(63, "A", 999, "Reserved private", "LLL"),
"64": ISO8583Field(64, "B", 16, "Message authentication code field"),
"65": ISO8583Field(65, "B", 16, "Bitmap, extended"),
"66": ISO8583Field(66, "N", 1, "Settlement code"),
"67": ISO8583Field(67, "N", 2, "Extended payment code"),
"68": ISO8583Field(68, "N", 3, "Receiving institution country code"),
"69": ISO8583Field(69, "N", 3, "Settlement institution country code"),
"70": ISO8583Field(70, "N", 3, "Network management information code"),
"71": ISO8583Field(71, "N", 4, "Message number"),
"72": ISO8583Field(72, "A", 999, "Data record", "LLL"),
"73": ISO8583Field(73, "N", 6, "Date, action"),
"74": ISO8583Field(74, "N", 10, "Credits, number"),
"75": ISO8583Field(75, "N", 10, "Credits, reversal number"),
"76": ISO8583Field(76, "N", 10, "Debits, number"),
"77": ISO8583Field(77, "N", 10, "Debits, reversal number"),
"78": ISO8583Field(78, "N", 10, "Transfer number"),
"79": ISO8583Field(79, "N", 10, "Transfer, reversal number"),
"80": ISO8583Field(80, "N", 10, "Inquiries number"),
"81": ISO8583Field(81, "N", 10, "Authorizations number"),
"82": ISO8583Field(82, "N", 12, "Credits, processing fee amount"),
"83": ISO8583Field(83, "N", 12, "Credits, transaction fee amount"),
"84": ISO8583Field(84, "N", 12, "Debits, processing fee amount"),
"85": ISO8583Field(85, "N", 12, "Debits, transaction fee amount"),
"86": ISO8583Field(86, "N", 16, "Credits, amount"),
"87": ISO8583Field(87, "N", 16, "Credits, reversal amount"),
"88": ISO8583Field(88, "N", 16, "Debits, amount"),
"89": ISO8583Field(89, "N", 16, "Debits, reversal amount"),
"90": ISO8583Field(90, "N", 42, "Original data elements"),
"91": ISO8583Field(91, "A", 1, "File update code"),
"92": ISO8583Field(92, "A", 2, "File security code"),
"93": ISO8583Field(93, "A", 5, "Response indicator"),
"94": ISO8583Field(94, "A", 7, "Service indicator"),
"95": ISO8583Field(95, "A", 42, "Replacement amounts"),
"96": ISO8583Field(96, "B", 8, "Message security code"),
"97": ISO8583Field(97, "N", 17, "Amount, net settlement"),
"98": ISO8583Field(98, "A", 25, "Payee"),
"99": ISO8583Field(99, "N", 11, "Settlement institution identification code", "LL"),
"100": ISO8583Field(100, "N", 11, "Receiving institution identification code", "LL"),
"101": ISO8583Field(101, "A", 17, "File name"),
"102": ISO8583Field(102, "A", 28, "Account identification 1", "LL"),
"103": ISO8583Field(103, "A", 28, "Account identification 2", "LL"),
"104": ISO8583Field(104, "A", 100, "Transaction description", "LLL"),
"105": ISO8583Field(105, "A", 999, "Reserved for ISO use", "LLL"),
"106": ISO8583Field(106, "A", 999, "Reserved for ISO use", "LLL"),
"107": ISO8583Field(107, "A", 999, "Reserved for ISO use", "LLL"),
"108": ISO8583Field(108, "A", 999, "Reserved for ISO use", "LLL"),
"109": ISO8583Field(109, "A", 999, "Reserved for ISO use", "LLL"),
"110": ISO8583Field(110, "A", 999, "Reserved for ISO use", "LLL"),
"111": ISO8583Field(111, "A", 999, "Reserved for ISO use", "LLL"),
"112": ISO8583Field(112, "A", 999, "Reserved for national use", "LLL"),
"113": ISO8583Field(113, "A", 999, "Reserved for national use", "LLL"),
"114": ISO8583Field(114, "A", 999, "Reserved for national use", "LLL"),
"115": ISO8583Field(115, "A", 999, "Reserved for national use", "LLL"),
"116": ISO8583Field(116, "A", 999, "Reserved for national use", "LLL"),
"117": ISO8583Field(117, "A", 999, "Reserved for national use", "LLL"),
"118": ISO8583Field(118, "A", 999, "Reserved for national use", "LLL"),
"119": ISO8583Field(119, "A", 999, "Reserved for national use", "LLL"),
"120": ISO8583Field(120, "A", 999, "Reserved for private use", "LLL"),
"121": ISO8583Field(121, "A", 999, "Reserved for private use", "LLL"),
"122": ISO8583Field(122, "A", 999, "Reserved for private use", "LLL"),
"123": ISO8583Field(123, "A", 999, "Reserved for private use", "LLL"),
"124": ISO8583Field(124, "A", 999, "Reserved for private use", "LLL"),
"125": ISO8583Field(125, "A", 999, "Reserved for private use", "LLL"),
"126": ISO8583Field(126, "A", 999, "Reserved for private use", "LLL"),
"127": ISO8583Field(127, "A", 999, "Reserved for private use", "LLL"),
"128": ISO8583Field(128, "B", 16, "Message authentication code") 
}

