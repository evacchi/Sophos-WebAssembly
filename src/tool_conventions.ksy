# https://github.com/WebAssembly/tool-conventions/

meta:
    id: webassembly
    title: Web Assembly Tool Conventions
    endian: le
    license: CC0-1.0
    imports:
      - vlq_base128_le


enums:
  payload_type:
    5: segment_info
    6: init_funcs
    7: comdat_info
    8: symbol_table

types:
  linking_custom_type:
    seq:
      - id: version
        type: vlq_base128_le
      - id: subsections
        type: linking_custom_subsection_type
        repeat: eos

  syminfo_type:
    seq:
      - id: kind
        type: u1
      - id: flags
        type: vlq_base128_le
      - id: name_len
        type: vlq_base128_le
        if: kind == 1 #and (flags.value & 0x40) == 0x40
      - id: name_data
        type: str
        encoding: UTF-8
        size: name_len.value
        if: kind == 1 #and (flags.value & 0x40) == 0x40
      - id: index
        type: vlq_base128_le
        if: kind == 1 #and (flags.value & 0x40) == 0x40
      - id: offset
        type: vlq_base128_le
        if: kind == 1 #and (flags.value & 0x40) == 0x40
      - id: size
        type: vlq_base128_le
        if: kind == 1 #and (flags.value & 0x40) == 0x40

  symbol_table_type:
    seq:
      - id: count
        type: vlq_base128_le
      - id: infos
        type: syminfo_type
        repeat: expr
        repeat-expr: count.value


  # https://github.com/WebAssembly/tool-conventions/blob/main/Linking.md
  linking_custom_subsection_type:
    seq:
      - id: type
        type: u1
      
      # raw payload
      - id: payload_len
        type: vlq_base128_le

      # symbols
      - id: symbol_table
        type: symbol_table_type
        size: payload_len.value
        if: type == 8

      - id: payload_data
        type: u1
        repeat: expr
        repeat-expr: payload_len.value
        if: type != 8
