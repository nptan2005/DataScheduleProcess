from ..ISO8583Message import *

class ISO8583Writer:
    def __init__(self, fields:dict[str,ISO8583Field]):
        self.fields = fields
        self.isoMessage = dict[str,str]

    def __calculate_rdw(self,message_length, byte_length: int):
        """
        Tính toán RDW (Record Descriptor Word) cho ISO 8583.

        Args:
        message_length (int): Độ dài của message (không bao gồm RDW).
        byte_length (int): Độ dài của RDW (2, 4, hoặc 8 bytes).

        Returns:
        str: Chuỗi nhị phân của RDW.
        """
        # Tính toán số bit cần thiết dựa trên số byte
        bit_length = byte_length * 8

        # Chuyển đổi độ dài từ thập phân sang nhị phân và đảm bảo độ dài bit phù hợp
        rdw_binary = format(message_length, f'0{bit_length}b')

        return rdw_binary

    def __generate_rdw(self,message_length:int,byte_length: int)->bytes:
        """
        Tạo chuỗi RDW (Record Descriptor Word) cho ISO 8583.

        Args:
            message_length (int): Độ dài của message (không bao gồm RDW).
            byte_length (int): Độ dài của RDW (2, 4, hoặc 8 bytes).
        Returns:
            bytes: Chuỗi RDW được mã hóa.
        """
        # print(f' độ dài input: {message_length}')
        binary_length = self.__calculate_rdw(message_length,byte_length)
        # print()
        # print(f'Binary: {binary_length}')
        # Tính toán số lượng ký tự hexadecimal cần thiết
        hex_digits = byte_length * 2
        hex_length = hex(int(binary_length, 2))[2:].zfill(hex_digits).upper()
        # print(f'Hex: {hex_length}')
        # Chuyển đổi hexadecimal sang chuỗi bytes
        rdw = bytes.fromhex(hex_length)
        # print(f'RDW: {rdw} | len {len(rdw)}')
        return rdw


    def write_iso8583_header(self,data: bytes) -> bytes:
        # Tính toán chiều dài của chuỗi
        if "h" in self.fields:
            headerField = self.fields["h"]
            if headerField.field_length > 0:
                length = len(data)

                # Chuyển đổi chiều dài thành bytes (4 bytes, big-endian)
                header = self.__generate_rdw(length,headerField.field_length)

                return header + data
        return data