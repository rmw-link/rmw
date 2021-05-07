const encoder = new TextEncoder();
const encode = encoder.encode.bind(encoder);
const decoder = new TextDecoder();
const decode = decoder.decode.bind(decoder);
var _pos_begin;
var li = (xml, tag)=>{
    var begin, end, pos, r, tag_len;
    r = [];
    begin = 0;
    tag_len = tag.length + 2;
    while(true){
        pos = xml.indexOf(`<${tag}>`, begin);
        if (pos < 0) {
            return r;
        }
        begin = pos + tag_len;
        end = xml.indexOf(`</${tag}>`, begin);
        if (end < 0) {
            return r;
        }
        r.push(xml.slice(begin, end).trim());
        begin = end + tag_len + 1;
    }
};
_pos_begin = (xml, tag, offset = 0)=>{
    var c, pos;
    pos = xml.indexOf(`<${tag}`, offset);
    if (pos < 0) {
        return -1;
    }
    pos = pos + tag.length + 1;
    c = xml.charAt(pos);
    switch(c){
        case ">":
            return pos + 1;
        case " ":
            pos = xml.indexOf(">", pos + 1);
            if (pos > 0) {
                return pos + 1;
            }
    }
    return -1;
};
var one = (xml, tag)=>{
    var begin, end;
    begin = _pos_begin(xml, tag);
    if (begin < 0) {
        return;
    }
    end = xml.indexOf(`</${tag}>`, begin);
    if (end < 0) {
        return;
    }
    return xml.slice(begin, end).trim();
};
var dict = (xml, tag_li)=>{
    var r, result, tag;
    result = {
    };
    for (tag of tag_li){
        r = one(xml, tag);
        if (r !== void 0) {
            result[tag] = r;
        }
    }
    return result;
};
var Xml = Xml = class Xml1 {
    constructor($1){
        this.$ = $1;
    }
    dict(tag_li) {
        return dict(this.$, tag_li);
    }
    li(tag) {
        return li(this.$, tag);
    }
    one(tag) {
        return one(this.$, tag);
    }
};
const __default = ($)=>{
    return new Xml($);
};
var M_SEARCH, SOAPAction, Udp, UpnpError, _SOAPAction, _control_url, fetch_xml;
M_SEARCH = encode(`M-SEARCH * HTTP/1.1\nHOST:239.255.255.250:1900\nMAN:"ssdp:discover"\nMX:3\nST:urn:schemas-upnp-org:device:InternetGatewayDevice:1`.replace(/\n/g, "\r\n"));
UpnpError = class UpnpError1 extends Error {
    constructor($){
        super($.faultstring + " " + $.errorCode + " : " + $.errorDescription);
        this.$ = $;
    }
};
Udp = ()=>{
    var addr, hostname, port, transport, udp;
    udp = Deno.listenDatagram({
        port: 0,
        transport: "udp",
        hostname: "0.0.0.0"
    });
    ({ addr  } = udp);
    ({ transport , hostname , port  } = addr);
    return udp;
};
fetch_xml = async (url, options = {
})=>{
    return __default(await (await fetch(url, options)).text());
};
var local_ip1 = async (hostname, port)=>{
    var socket;
    socket = await Deno.connect({
        port,
        hostname
    });
    socket.close();
    return socket.localAddr.hostname;
};
_SOAPAction = class _SOAPAction1 {
    constructor(url, serviceType1){
        this.serviceType = serviceType1;
        this.url = url;
        this.URL = new URL(url);
        this.GetGenericPortMappingEntry = this._("GetGenericPortMappingEntry");
        this.AddPortMapping = this._("AddPortMapping");
    }
    async mapPort(protocol, internal, external, duration = 0, description = "") {
        var hostname, ip, port;
        ({ hostname , port  } = this.URL);
        ip = await local_ip1(hostname, parseInt(port || 80));
        return this.AddPortMapping(`<NewRemoteHost></NewRemoteHost><NewExternalPort>${external}</NewExternalPort><NewProtocol>${protocol}</NewProtocol><NewInternalPort>${internal}</NewInternalPort><NewInternalClient>${ip}</NewInternalClient><NewEnabled>1</NewEnabled><NewPortMappingDescription>${description}</NewPortMappingDescription><NewLeaseDuration>${duration}</NewLeaseDuration>`);
    }
    async map() {
        var err, i, li1, n, r, ref;
        li1 = [];
        n = 0;
        while(true){
            try {
                r = await this.GetGenericPortMappingEntry(`<NewPortMappingIndex>${n++}</NewPortMappingIndex>`);
            } catch (error1) {
                err = error1;
                if (err.$.errorCode === "713") {
                    break;
                }
                throw err;
            }
            r = __default(r);
            r = r.dict([
                'NewPortMappingDescription',
                'NewProtocol',
                'NewInternalClient',
                'NewRemoteHost',
                'NewInternalPort',
                'NewExternalPort',
                'NewEnabled',
                'NewLeaseDuration'
            ]);
            ref = [
                'NewInternalPort',
                'NewExternalPort',
                'NewEnabled',
                'NewLeaseDuration'
            ];
            for (i of ref){
                r[i] = parseInt(r[i]);
            }
            li1.push(r);
        }
        return li1;
    }
    _(action) {
        var body_begin, body_end, headers, response, serviceType, url1;
        ({ url: url1 , serviceType  } = this);
        response = `u:${action}Response`;
        headers = {
            "Content-Type": "text/xml",
            SOAPAction: `${serviceType}#${action}`
        };
        body_begin = `<?xml version="1.0"?>\n<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:${action} xmlns:u="${serviceType}">`;
        body_end = `</u:${action}></s:Body></s:Envelope>`;
        return async (body)=>{
            var error, r, result;
            r = await fetch_xml(url1, {
                method: 'POST',
                headers,
                body: body_begin + body + body_end
            });
            result = r.one(response);
            if (result === void 0) {
                error = r.one("s:Fault");
                if (error) {
                    error = __default(error).dict([
                        "errorCode",
                        "errorDescription",
                        "faultstring",
                        "faultcode"
                    ]);
                    throw new UpnpError(error);
                }
            }
            return result;
        };
    }
};
SOAPAction = function() {
    return new _SOAPAction(...arguments);
};
_control_url = async (url2)=>{
    var URLBase, controlURL, ref, serviceType, x, xml;
    xml = await fetch_xml(url2);
    URLBase = xml.one('URLBase');
    if (!URLBase) {
        url2 = new URL(url2);
        URLBase = url2.origin;
    }
    ref = xml.li('service');
    for (x of ref){
        x = __default(x);
        serviceType = x.one('serviceType');
        if ([
            "urn:schemas-upnp-org:service:WANIPConnection:1",
            "urn:schemas-upnp-org:service:WANPPPConnection:1"
        ].indexOf(serviceType) + 1) {
            controlURL = URLBase + x.one('controlURL');
            break;
        }
    }
    if (controlURL) {
        return SOAPAction(controlURL, serviceType);
    }
};
const __default1 = async ()=>{
    var i, msg, remote, udp, url2;
    udp = Udp();
    udp.send(M_SEARCH, {
        hostname: "239.255.255.250",
        port: 1900,
        transport: "udp"
    });
    [msg, remote] = await udp.receive(new Uint8Array(1472));
    msg = decode(msg);
    msg = msg.replace(/\r/g, '').split("\n");
    for (i of msg){
        if (i.startsWith("LOCATION:")) {
            url2 = i.slice(9).trim();
            break;
        }
    }
    if (url2) {
        return _control_url(url2);
    }
};
export { __default1 as default };
export { local_ip1 as local_ip };

