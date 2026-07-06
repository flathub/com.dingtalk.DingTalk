#!/bin/bash
if [[ "$XMODIFIERS" =~ fcitx ]]; then
    [ -z "$QT_IM_MODULE" ] && export QT_IM_MODULE=fcitx
    [ -z "$GTK_IM_MODULE" ] && export GTK_IM_MODULE=fcitx
elif [[ "$XMODIFIERS" =~ ibus ]]; then
    [ -z "$QT_IM_MODULE" ] && export QT_IM_MODULE=ibus
    [ -z "$GTK_IM_MODULE" ] && export GTK_IM_MODULE=ibus
fi

# DingTalk does not ship the Qt Wayland platform plugin; keep it on Xwayland.
export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-xcb}"
export QT_PLUGIN_PATH=/app/extra/dingtalk/release:$QT_PLUGIN_PATH

dingtalk_preload=/app/lib/libdingtalk_ssl_peer_certificate_shim.so
if [ -n "${WAYLAND_DISPLAY:-}" ] || [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
    dingtalk_preload=/app/lib/libdingtalk_wayland_screenshare.so:$dingtalk_preload
fi
export LD_PRELOAD=$dingtalk_preload${LD_PRELOAD:+:$LD_PRELOAD}

cd "/app/extra/dingtalk/release" || exit 1
./com.alibabainc.dingtalk "$@"
