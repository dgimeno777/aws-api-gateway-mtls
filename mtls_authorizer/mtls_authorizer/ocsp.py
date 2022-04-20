import ssl
import requests
from loguru import logger
from base64 import b64encode
from urllib.parse import urljoin
from cryptography.x509 import Certificate, load_pem_x509_certificate
from cryptography.x509.ocsp import (
    OCSPCertStatus,
    OCSPRequestBuilder,
    load_der_ocsp_response
)
from cryptography.x509.oid import ExtensionOID, AuthorityInformationAccessOID
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.hashes import SHA256


def convert_pem_to_x509(cert_pem: str) -> Certificate:
    """
    Converts a PEM format certificate to a cryptography x509 object
    :param cert_pem: the certificate in the PEM format
    :return: the certificate as a cryptography x509 object
    """
    return load_pem_x509_certificate(cert_pem.encode('ascii'), default_backend())


def convert_der_to_pem(cert_der) -> str:
    """
    Convert a DER format certificate to a PEM format certificate as a string
    :param cert_der: the certificate in the DER format
    :return:
    """
    return ssl.DER_cert_to_PEM_cert(cert_der)


def get_ca_issuer_url(cert: Certificate) -> str:
    """
    Gets the URL of the certificate CA issuer
    :param cert: the certificate
    :return: the URL of the CA issuer
    """
    aia = cert.extensions.get_extension_for_oid(ExtensionOID.AUTHORITY_INFORMATION_ACCESS).value
    issuers = [ia for ia in aia if ia.access_method == AuthorityInformationAccessOID.CA_ISSUERS]
    if not issuers:
        raise Exception('No issuers entry in AIA')
    return issuers[0].access_location.value


def get_ocsp_server_url(cert: Certificate) -> str:
    """
    Gets the URL of the certificat OCSP Server
    :param cert:
    :return:
    """
    aia = cert.extensions.get_extension_for_oid(ExtensionOID.AUTHORITY_INFORMATION_ACCESS).value
    ocsp_servers = [ia for ia in aia if ia.access_method == AuthorityInformationAccessOID.OCSP]
    if not ocsp_servers:
        raise Exception('No ocsp server entry in AIA')
    return ocsp_servers[0].access_location.value


def get_issuer_cert(ca_issuer_url: str) -> Certificate:
    """
    Gets the certificate of the ca_issuer
    :param ca_issuer_url: the ca
    :return:
    """
    issuer_response = requests.get(ca_issuer_url)
    if issuer_response.ok:
        issuer_der = issuer_response.content
        issuer_pem = convert_der_to_pem(issuer_der)
        return convert_pem_to_x509(issuer_pem)
    raise Exception(f'fetching issuer cert  failed with response status: {issuer_response.status_code}')


def build_ocsp_request(ocsp_server_url: str, cert: Certificate, issuer_cert: Certificate) -> str:
    """
    Builds an OCSP request and returns a populated request URL
    :param ocsp_server_url: the URL of the OCSP server
    :param cert: the cert for the status check
    :param issuer_cert: the cert of the issuer CA
    :return:
    """
    builder = OCSPRequestBuilder()
    builder = builder.add_certificate(cert, issuer_cert, SHA256())
    req = builder.build()
    req_path = b64encode(req.public_bytes(serialization.Encoding.DER))
    return urljoin(ocsp_server_url + '/', req_path.decode('ascii'))


def do_ocsp_request(ocsp_server_url: str, cert: Certificate, issuer_cert: Certificate) -> OCSPCertStatus:
    """
    Does an OCSP request and returns the status of the certificate
    :param ocsp_server_url: the URL of the OCSP server
    :param cert: the cert for status checking
    :param issuer_cert: the cert of the issuer CA
    :return: the status of the certificate
    """
    ocsp_resp = requests.get(build_ocsp_request(ocsp_server_url, cert, issuer_cert))
    if ocsp_resp.ok:
        logger.info(f'OCSP Response: {convert_der_to_pem(ocsp_resp.content)}')
        ocsp_decoded = load_der_ocsp_response(ocsp_resp.content)
        for response in ocsp_decoded.responses:
            if response.certificate_status == OCSPCertStatus.GOOD:
                return response.certificate_status
            else:
                logger.error(f'Decoding OCSP response failed: {response.certificate_status}')
    logger.error(f'Fetching OCSP cert status failed with response status: {ocsp_resp.status_code}')
    return OCSPCertStatus.UNKNOWN


def get_ocsp_cert_status(cert_pem: str) -> OCSPCertStatus:
    """
    Gets the status of a certificate via OCSP
    :param cert_pem: the PEM of the certificate to check
    :return: the status of the certificate
    """
    # Convert PEM certificate to Certificate object type
    cert = convert_pem_to_x509(cert_pem)

    # Get the issuer of the certificate
    ca_issuer_url = get_ca_issuer_url(cert)

    # Get the certificate of the issuer
    issuer_cert = get_issuer_cert(ca_issuer_url)

    # Get OCSP server of the certificate
    ocsp_server_url = get_ocsp_server_url(cert)

    logger.info(f"CA: {ca_issuer_url}")
    logger.info(f"OCSP: {ocsp_server_url}")

    # Do the OCSP request and return the result
    return do_ocsp_request(
        ocsp_server_url=ocsp_server_url,
        cert=cert,
        issuer_cert=issuer_cert
    )
