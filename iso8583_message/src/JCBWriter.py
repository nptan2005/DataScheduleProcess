from ..ISO8583Message.JCBbitmap import JCBfields
from ..ISO8583Message.JCBExtensionFormat import bit55Format, bit54Format, bit43Format, bit97Format
from ..ISO8583Message import *
from ..ISO8583Message.JCBPDEFormat import *
from ..ISO8583Message.ISO8583Writer import ISO8583Writer

class JCBWriter(ISO8583Writer):
    def __init__(self, fields: dict[str, ISO8583Field] = JCBfields):
        super().__init__(fields)
