// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://sms.kmsoftclub.ir/webservice/soap/smsService.php?wsdl
//  >Import : http://sms.kmsoftclub.ir/webservice/soap/smsService.php?wsdl>0
// Encoding : ISO-8859-1
// Version  : 1.0
// (06/07/2015 11:42:05 Þ.Ù - - $Rev: 69934 $)
// ************************************************************************ //

unit smsService;

interface

uses Soap.InvokeRegistry, Soap.SOAPHTTPClient, System.Types, Soap.XSBuiltIns;

type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Embarcadero types; however, they could also
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:long            - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:int             - "http://www.w3.org/2001/XMLSchema"[Gbl]

  array_number_in_cat  = class;                 { "urn:sms_webservice_wsdl"[GblCplx] }
  return_array_user_info = class;               { "urn:sms_webservice_wsdl"[GblCplx] }
  array_number         = class;                 { "urn:sms_webservice_wsdl"[GblCplx] }
  array_number_state   = class;                 { "urn:sms_webservice_wsdl"[GblCplx] }
  array_receive        = class;                 { "urn:sms_webservice_wsdl"[GblCplx] }
  array_tree           = class;                 { "urn:sms_webservice_wsdl"[GblCplx] }
  array_cat_list       = class;                 { "urn:sms_webservice_wsdl"[GblCplx] }

  return_array_number_in_cat = array of array_number_in_cat;   { "urn:sms_webservice_wsdl"[GblCplx] }
  return_array_number = array of array_number;   { "urn:sms_webservice_wsdl"[GblCplx] }
  return_array_tree = array of array_tree;      { "urn:sms_webservice_wsdl"[GblCplx] }
  return_array_receive = array of array_receive;   { "urn:sms_webservice_wsdl"[GblCplx] }
  ArrayOfInteger = array of Int64;              { "urn:sms_webservice_wsdl"[GblCplx] }
  ArrayOfString = array of string;              { "urn:sms_webservice_wsdl"[GblCplx] }


  // ************************************************************************ //
  // XML       : array_number_in_cat, global, <complexType>
  // Namespace : urn:sms_webservice_wsdl
  // ************************************************************************ //
  array_number_in_cat = class(TRemotable)
  private
    Fid: string;
    Ffullname: string;
    Fnumber: string;
    Fdate: string;
    Fgender: string;
    Ffullname_en: string;
  published
    property id:          string  read Fid write Fid;
    property fullname:    string  read Ffullname write Ffullname;
    property number:      string  read Fnumber write Fnumber;
    property date:        string  read Fdate write Fdate;
    property gender:      string  read Fgender write Fgender;
    property fullname_en: string  read Ffullname_en write Ffullname_en;
  end;



  // ************************************************************************ //
  // XML       : return_array_user_info, global, <complexType>
  // Namespace : urn:sms_webservice_wsdl
  // ************************************************************************ //
  return_array_user_info = class(TRemotable)
  private
    Fid: string;
    Ffullname: string;
    Femail: string;
    Fmobile: string;
    Fcash: string;
    Fdate: string;
    Fdate_expire: string;
  published
    property id:          string  read Fid write Fid;
    property fullname:    string  read Ffullname write Ffullname;
    property email:       string  read Femail write Femail;
    property mobile:      string  read Fmobile write Fmobile;
    property cash:        string  read Fcash write Fcash;
    property date:        string  read Fdate write Fdate;
    property date_expire: string  read Fdate_expire write Fdate_expire;
  end;



  // ************************************************************************ //
  // XML       : array_number, global, <complexType>
  // Namespace : urn:sms_webservice_wsdl
  // ************************************************************************ //
  array_number = class(TRemotable)
  private
    Fnumber: string;
    Forder: string;
    Fkind: string;
  published
    property number: string  read Fnumber write Fnumber;
    property order:  string  read Forder write Forder;
    property kind:   string  read Fkind write Fkind;
  end;



  // ************************************************************************ //
  // XML       : array_number_state, global, <complexType>
  // Namespace : urn:sms_webservice_wsdl
  // ************************************************************************ //
  array_number_state = class(TRemotable)
  private
    Fnumber: string;
    Fstate: string;
  published
    property number: string  read Fnumber write Fnumber;
    property state:  string  read Fstate write Fstate;
  end;



  // ************************************************************************ //
  // XML       : array_receive, global, <complexType>
  // Namespace : urn:sms_webservice_wsdl
  // ************************************************************************ //
  array_receive = class(TRemotable)
  private
    Fid: string;
    Fsender_number: string;
    Freceiver_number: string;
    Fdate: string;
    Fcatid: string;
    Fnote: string;
    Fread_: Integer;
  published
    property id:              string   read Fid write Fid;
    property sender_number:   string   read Fsender_number write Fsender_number;
    property receiver_number: string   read Freceiver_number write Freceiver_number;
    property date:            string   read Fdate write Fdate;
    property catid:           string   read Fcatid write Fcatid;
    property note:            string   read Fnote write Fnote;
    property read_:           Integer  read Fread_ write Fread_;
  end;



  // ************************************************************************ //
  // XML       : array_tree, global, <complexType>
  // Namespace : urn:sms_webservice_wsdl
  // ************************************************************************ //
  array_tree = class(TRemotable)
  private
    Fid: Integer;
    Fname_: string;
  published
    property id:    Integer  read Fid write Fid;
    property name_: string   read Fname_ write Fname_;
  end;

  return_array_cat_list = array of array_cat_list;   { "urn:sms_webservice_wsdl"[GblCplx] }
  return_array_number_state = array of array_number_state;   { "urn:sms_webservice_wsdl"[GblCplx] }


  // ************************************************************************ //
  // XML       : array_cat_list, global, <complexType>
  // Namespace : urn:sms_webservice_wsdl
  // ************************************************************************ //
  array_cat_list = class(TRemotable)
  private
    Fid: string;
    Ftitle: string;
    Fdate: string;
    Fnumber: Integer;
  published
    property id:     string   read Fid write Fid;
    property title:  string   read Ftitle write Ftitle;
    property date:   string   read Fdate write Fdate;
    property number: Integer  read Fnumber write Fnumber;
  end;


  // ************************************************************************ //
  // Namespace : sms_webservice_wsdl
  // soapAction: sms_webservice_wsdl#%operationName%
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : rpc
  // use       : encoded
  // binding   : SmsPanelWebserviceBinding
  // service   : SmsPanelWebservice
  // port      : SmsPanelWebservicePort
  // URL       : http://sms.kmsoftclub.ir/webservice/soap/smsService.php
  // ************************************************************************ //
  SmsPanelWebservicePortType = interface(IInvokable)
  ['{5D573584-EF4E-3DD1-BDE4-C0EF9F573F81}']
    function  sms_get_number_in_cat(const username: string; const password: string; const catid: Integer; const start: Integer; const perpage: Integer; const order: string
                                    ): return_array_number_in_cat; stdcall;
    function  sms_get_cat_list(const username: string; const password: string): return_array_cat_list; stdcall;
    function  send_sms(const username: string; const password: string; const sender_number: ArrayOfString; const receiver_number: ArrayOfString; const note: ArrayOfString; const date: ArrayOfString;
                       const request_uniqueid: ArrayOfString; const flash: ArrayOfString; const onlysend: string): ArrayOfString; stdcall;
    function  get_number(const username: string; const password: string): return_array_number; stdcall;
    function  sms_deliver(const smsid_arr: ArrayOfString; const dargah: Integer): ArrayOfInteger; stdcall;
    function  is_number_in_blacklist(const number: ArrayOfString): return_array_number_state; stdcall;
    function  add_user(const admin_username: string; const admin_password: string; const username: string; const password: string; const email: string; const fullname: string;
                       const mobile: string; const catid: Integer): string; stdcall;
    function  sms_user_info(const username: string; const password: string): return_array_user_info; stdcall;
    function  sms_credit(const username: string; const password: string): Integer; stdcall;
    function  sms_add_number(const username: string; const password: string; const fullname: string; const number: string; const catid: Integer; const gender: string;
                             const fullname_en: string; const gender_en: string): string; stdcall;
    function  sms_receive(const username: string; const password: string; const number: string; const catid: Integer; const start: Integer; const perpage: Integer;
                          const read_: Integer; const order: string): return_array_receive; stdcall;
    function  sms_receive_change_read(const username: string; const password: string; const id: ArrayOfInteger; const read_: Integer): string; stdcall;
    function  sms_count_bulk_gender(const bankid: string; const gender: Integer; const receiver_number_kind: string; const age_start: Integer; const age_end: Integer; const receiver_number_perfix: Integer;
                                    const dargah: Integer): string; stdcall;
    function  sms_send_bulk_gender(const username: string; const password: string; const sender_number: string; const bankid: string; const note: string; const date: Integer;
                                   const record_start: Integer; const receiver_count: Integer; const gender: Integer; const receiver_number_kind: string; const age_start: Integer;
                                   const age_end: Integer; const receiver_number_perfix: Integer; const billing_title: string; const request_uniqueid: string; const dargah: Integer
                                   ): string; stdcall;
    function  sms_count_bank_gender(const parentid: Integer; const dargah: Integer): return_array_tree; stdcall;
    function  user_add_cat(const username: string; const password: string; const title: ArrayOfString): ArrayOfInteger; stdcall;
    function  convert_unixtime_to_jalali(const date: Integer): string; stdcall;
    function  number_query(const number: string): string; stdcall;
    function  convert_jalali_to_unixtimestamp(const year: Integer; const month: Integer; const day: Integer; const hour: Integer; const minute: Integer): string; stdcall;
    function  admin_allow_number_new(const username: string; const password: string; const adminid: ArrayOfString; const number: ArrayOfString; const dargah: ArrayOfString): return_array_number_state; stdcall;
  end;

function GetSmsPanelWebservicePortType(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): SmsPanelWebservicePortType;


implementation
  uses System.SysUtils;

function GetSmsPanelWebservicePortType(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): SmsPanelWebservicePortType;
const
  defWSDL = 'http://sms.kmsoftclub.ir/webservice/soap/smsService.php?wsdl';
  defURL  = 'http://sms.kmsoftclub.ir/webservice/soap/smsService.php';
  defSvc  = 'SmsPanelWebservice';
  defPrt  = 'SmsPanelWebservicePort';
var
  RIO: THTTPRIO;
begin
  Result := nil;
  if (Addr = '') then
  begin
    if UseWSDL then
      Addr := defWSDL
    else
      Addr := defURL;
  end;
  if HTTPRIO = nil then
    RIO := THTTPRIO.Create(nil)
  else
    RIO := HTTPRIO;
  try
    Result := (RIO as SmsPanelWebservicePortType);
    if UseWSDL then
    begin
      RIO.WSDLLocation := Addr;
      RIO.Service := defSvc;
      RIO.Port := defPrt;
    end else
      RIO.URL := Addr;
  finally
    if (Result = nil) and (HTTPRIO = nil) then
      RIO.Free;
  end;
end;


initialization
  { SmsPanelWebservicePortType }
  InvRegistry.RegisterInterface(TypeInfo(SmsPanelWebservicePortType), 'sms_webservice_wsdl', 'ISO-8859-1');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(SmsPanelWebservicePortType), 'sms_webservice_wsdl#%operationName%');
  { SmsPanelWebservicePortType.sms_receive }
  InvRegistry.RegisterParamInfo(TypeInfo(SmsPanelWebservicePortType), 'sms_receive', 'read_', 'read', '');
  { SmsPanelWebservicePortType.sms_receive_change_read }
  InvRegistry.RegisterParamInfo(TypeInfo(SmsPanelWebservicePortType), 'sms_receive_change_read', 'read_', 'read', '');
  RemClassRegistry.RegisterXSInfo(TypeInfo(return_array_number_in_cat), 'urn:sms_webservice_wsdl', 'return_array_number_in_cat');
  RemClassRegistry.RegisterXSInfo(TypeInfo(return_array_number), 'urn:sms_webservice_wsdl', 'return_array_number');
  RemClassRegistry.RegisterXSInfo(TypeInfo(return_array_tree), 'urn:sms_webservice_wsdl', 'return_array_tree');
  RemClassRegistry.RegisterXSInfo(TypeInfo(return_array_receive), 'urn:sms_webservice_wsdl', 'return_array_receive');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfInteger), 'urn:sms_webservice_wsdl', 'ArrayOfInteger');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfString), 'urn:sms_webservice_wsdl', 'ArrayOfString');
  RemClassRegistry.RegisterXSClass(array_number_in_cat, 'urn:sms_webservice_wsdl', 'array_number_in_cat');
  RemClassRegistry.RegisterXSClass(return_array_user_info, 'urn:sms_webservice_wsdl', 'return_array_user_info');
  RemClassRegistry.RegisterXSClass(array_number, 'urn:sms_webservice_wsdl', 'array_number');
  RemClassRegistry.RegisterXSClass(array_number_state, 'urn:sms_webservice_wsdl', 'array_number_state');
  RemClassRegistry.RegisterXSClass(array_receive, 'urn:sms_webservice_wsdl', 'array_receive');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(array_receive), 'read_', '[ExtName="read"]');
  RemClassRegistry.RegisterXSClass(array_tree, 'urn:sms_webservice_wsdl', 'array_tree');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(array_tree), 'name_', '[ExtName="name"]');
  RemClassRegistry.RegisterXSInfo(TypeInfo(return_array_cat_list), 'urn:sms_webservice_wsdl', 'return_array_cat_list');
  RemClassRegistry.RegisterXSInfo(TypeInfo(return_array_number_state), 'urn:sms_webservice_wsdl', 'return_array_number_state');
  RemClassRegistry.RegisterXSClass(array_cat_list, 'urn:sms_webservice_wsdl', 'array_cat_list');

end.
