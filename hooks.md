# Hooks en Claude Code

## ¿Qué es un hook?

Un **hook** es un disparador automático. Le dices al sistema "cuando ocurra X, ejecuta Y", y él lo lanza solo, sin que nadie lo pida.

Ejemplo: "cuando Claude termine de responder, ejecuta el script de git."

---

## Hook vs Skill

Dos conceptos que se confunden fácilmente:

| | Hook | Skill |
|---|---|---|
| ¿Quién lo activa? | El sistema solo, al ocurrir un evento | Tú, escribiendo `/nombre` |
| ¿Cuándo? | Automáticamente | Cuando tú lo pides |
| Ejemplo | "Al terminar, sube a git" | `/review`, `/security-review` |

---

## Tipos de eventos (cuándo se puede disparar un hook)

| Evento | Cuándo se dispara |
|---|---|
| `Stop` | Cuando Claude termina de responder |
| `PreToolUse` | Antes de que Claude use una herramienta (leer fichero, ejecutar comando…) |
| `PostToolUse` | Después de que Claude use una herramienta |
| `SessionStart` | Al iniciar una sesión |
| `PreCompact` | Antes de que el sistema comprima el historial de conversación |

---

## Dónde se configura

En el fichero `.claude/settings.local.json` dentro del repositorio. Ejemplo de estructura:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "shell": "bash",
            "statusMessage": "Mensaje que se muestra mientras se ejecuta...",
            "command": "el comando que quieres ejecutar"
          }
        ]
      }
    ]
  }
}
```

---

## El hook configurado en este proyecto

### Propósito

Automatizar la integración con GitHub: cada vez que Claude termina una tarea en la que ha modificado ficheros, los cambios se guardan y suben a GitHub sin intervención manual.

### Los tres pasos de git que se automatizan

1. **`git add`** — Marca los ficheros modificados para ser guardados
2. **`git commit`** — Graba una "foto" del estado actual con un mensaje descriptivo
3. **`git push`** — Sube esa foto a GitHub

### Arquitectura en dos capas

El sistema usa dos mecanismos complementarios para que el mensaje del commit sea significativo:

**Capa 1 — Claude (mensaje con sentido)**
Claude genera un resumen en español de lo que hizo (ej. *"Añadir sección de requisitos a miTeclado.md"*) y ejecuta los tres comandos git al terminar cada tarea. Esto produce mensajes de commit descriptivos.

**Capa 2 — Hook Stop (red de seguridad)**
Se dispara automáticamente al terminar cada respuesta. Comprueba si hay cambios sin guardar. Si Claude ya hizo el commit (capa 1), no encuentra nada y termina. Si Claude se olvidó, hace el commit con un mensaje genérico (lista de ficheros modificados).

```
Claude termina de responder
         │
         ▼
  ¿Cambios sin guardar?
    │           │
   NO           SÍ
    │           │
  Fin      git add -A
           git commit -m "Auto: ficheros..."
           git push
```

### El comando del hook

```bash
if ! git status --porcelain 2>/dev/null | grep -q .; then exit 0; fi
CHANGED=$(git status --porcelain | awk '{print $NF}' | tr '\n' ', ' | sed 's/,$//');
git add -A && git commit -m "Auto: $CHANGED" && git push 2>/dev/null || true
```

Paso a paso:
1. Si no hay cambios → salir sin hacer nada
2. Obtener la lista de ficheros modificados
3. Hacer `git add -A`, `git commit` y `git push`
4. Si el push falla (sin red, etc.) → ignorar el error y no bloquear

### Permisos añadidos

Se añadió `Bash(git *)` al fichero de configuración para que Claude pueda ejecutar comandos git sin pedir confirmación cada vez.

---

## Para que los hooks funcionen

Después de modificar `.claude/settings.local.json`, hay que **reiniciar Claude Code** o abrir el menú `/hooks` una vez para que recargue la configuración.
