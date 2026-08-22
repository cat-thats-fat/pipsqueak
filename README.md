# pipsqueak

Plasma 6 widget that sends a prompt to an OpenAI-compatible
`/v1/chat/completions` endpoint and shows the reply.

Default endpoint: `http://localhost:11434`.

## Install

```
git clone https://github.com/cat-thats-fat/pipsqueak.git
cd pipsqueak
kpackagetool6 --type Plasma/Applet --install .
```

Update with `--upgrade` instead of `--install`.

Add it from the Plasma widget picker.

## Configure

Right-click the widget → Configure → General → Ollama Instance URL.

## License

GPL-3.0
