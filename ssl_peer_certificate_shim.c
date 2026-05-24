#define _GNU_SOURCE

#include <dlfcn.h>
#include <string.h>

typedef struct ssl_st SSL;
typedef struct x509_st X509;

typedef X509 *(*ssl_get_peer_certificate_fn)(const SSL *ssl);

X509 *
SSL_get_peer_certificate(const SSL *ssl)
{
    static ssl_get_peer_certificate_fn real_SSL_get_peer_certificate;
    void *caller = __builtin_return_address(0);
    Dl_info info;

    if (!real_SSL_get_peer_certificate) {
        real_SSL_get_peer_certificate =
            (ssl_get_peer_certificate_fn)dlsym(RTLD_NEXT, "SSL_get_peer_certificate");
    }

    /*
     * DingTalk 8.1.0 crashes in libutforpc.so's bundled curl servercert path
     * while OpenSSL up-refs the peer certificate. Limit the workaround to that
     * caller so other components keep their normal certificate handling.
     */
    if (caller && dladdr(caller, &info) && info.dli_fname &&
        strstr(info.dli_fname, "/libutforpc.so")) {
        return 0;
    }

    if (real_SSL_get_peer_certificate) {
        return real_SSL_get_peer_certificate(ssl);
    }

    return 0;
}
