# CORS Proxy Setup für Kalender-Import

## Problem
Die BBZW-Website (`schulnetz.lu.ch`) erlaubt keine CORS-Anfragen von externen Domains, was den direkten Kalender-Import blockiert.

## Lösung: Serverless CORS Proxy

### Für Vercel (bereits konfiguriert)

Die Datei `api/cors-proxy.js` ist bereits erstellt. Vercel erkennt automatisch Funktionen im `/api` Ordner.

**Endpoint:** `https://absendo.artur.engineer/api/cors-proxy?url=...`

### Für Coolify (alternative Lösungen)

#### Option 1: Supabase Edge Function (empfohlen)

Erstelle eine Edge Function in Supabase:

```bash
# In deinem Supabase Projekt
supabase functions new cors-proxy
```

```typescript
// supabase/functions/cors-proxy/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const url = new URL(req.url).searchParams.get('url')
  
  if (!url || !url.startsWith('https://schulnetz.lu.ch/bbzw')) {
    return new Response(JSON.stringify({ error: 'Invalid URL' }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' }
    })
  }

  const response = await fetch(url)
  const data = await response.text()

  return new Response(data, {
    headers: {
      'Content-Type': 'text/calendar',
      'Access-Control-Allow-Origin': '*',
      'Cache-Control': 'public, max-age=300'
    }
  })
})
```

**Endpoint:** `https://supabasekong-xk0okwos88kcook0ks4ckswc.artur.engineer/functions/v1/cors-proxy?url=...`

#### Option 2: Nginx Reverse Proxy

Füge zu deiner Nginx-Konfiguration hinzu:

```nginx
location /api/cors-proxy {
    if ($arg_url !~ "^https://schulnetz\.lu\.ch/bbzw") {
        return 400;
    }
    
    proxy_pass $arg_url;
    proxy_set_header User-Agent "Absendo/1.0";
    
    add_header Access-Control-Allow-Origin *;
    add_header Access-Control-Allow-Methods GET;
    add_header Cache-Control "public, max-age=300";
}
```

## Environment Variable

Setze in Coolify:

```bash
VITE_CORS_PROXY_URL=https://absendo.artur.engineer/api/cors-proxy
# oder für Supabase Edge Function:
# VITE_CORS_PROXY_URL=https://supabasekong-xk0okwos88kcook0ks4ckswc.artur.engineer/functions/v1/cors-proxy
```

## Testing

```bash
# Test the proxy
curl "https://absendo.artur.engineer/api/cors-proxy?url=https://schulnetz.lu.ch/bbzw/cindex.php?longurl=..."
```

## Sicherheit

- ✅ Nur `schulnetz.lu.ch/bbzw` URLs erlaubt
- ✅ Keine Weitergabe von Credentials
- ✅ Caching für Performance (5 Minuten)
- ✅ Rate-Limiting über Vercel/Supabase
