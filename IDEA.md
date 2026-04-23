## WFL Lang — Stack e Architettura

### Identità del linguaggio

Un linguaggio compilato per BEAM pensato per **business workflow con parallelismo nativo**. Non un framework, non un DSL embedded — un linguaggio autonomo con la sua sintassi, il suo compilatore, e semantica orientata ai processi. Ispirato concettualmente a BPML/BPMN ma con sintassi da linguaggio moderno.

---

### Stack tecnologico

**Linguaggio del compilatore:** Erlang puro
Nessuna dipendenza esterna. Il compilatore stesso gira su BEAM e usa solo stdlib Erlang.

**Build tool:** rebar3
Standard de facto per progetti Erlang. Gestisce la compilazione automatica di `.xrl` e `.yrl`.

**Lexer:** Leex (`.xrl`)
Generatore di lexer basato su espressioni regolari, nativo Erlang. Produce un modulo `.erl` compilabile.

**Parser:** Yecc (`.yrl`)
Generatore di parser LALR(1), nativo Erlang. Equivalente a yacc/bison ma per BEAM. Produce un modulo `.erl` compilabile.

**Target di compilazione:** Erlang Core IR
Il compilatore genera **Erlang source** (`.erl`) come rappresentazione intermedia, poi delega a `compile:file/1` per produrre `.beam`. Questo evita di dover gestire il bytecode BEAM direttamente e permette di ispezionare l'output a occhio nudo durante lo sviluppo.

**Runtime:** OTP standard
Nessun runtime custom. Ogni workflow compila in un modulo OTP standard — GenServer, Supervisor, Task — usando le primitive già presenti nella BEAM.

---

### Struttura del repository

```
wfl_lang/
├── rebar.config
├── src/
│   ├── wfl_lang.app.src
│   ├── wfl_lexer.xrl          ← tokenizer Leex
│   ├── wfl_parser.yrl         ← parser Yecc LALR(1)
│   ├── wfl_ast.erl            ← definizione tipi AST
│   ├── wfl_validator.erl      ← validazione semantica AST
│   ├── wfl_codegen.erl        ← AST → Erlang source
│   ├── wfl_compiler.erl       ← entry point pubblico
│   └── wfl_cli.erl            ← interfaccia escript CLI
├── include/
│   └── wfl_ast.hrl            ← record definitions AST
├── test/
│   ├── wfl_lexer_SUITE.erl
│   ├── wfl_parser_SUITE.erl
│   └── wfl_codegen_SUITE.erl
├── examples/
│   └── order_processing.wfl   ← esempio di riferimento
└── priv/
    └── wfl                    ← escript binario compilato
```

---

### Pipeline di compilazione

```
source.wfl
    │
    ▼
wfl_lexer        (Leex)
Token list: [{workflow,1}, {var,1,'OrderFlow'}, ...]
    │
    ▼
wfl_parser       (Yecc LALR-1)
AST Erlang terms: {workflow, 'OrderFlow', [...]}
    │
    ▼
wfl_validator
Controlli semantici: step duplicati, riferimenti non risolti,
cicli nel grafo dei workflow, tipi di compensazione validi
    │
    ▼
wfl_codegen
Erlang source .erl con moduli OTP
    │
    ▼
compile:file/1
.beam — gira direttamente su BEAM
```

---

### Mapping semantico: costrutti WFL → OTP

| Costrutto WFL | Primitiva OTP | Note |
|---|---|---|
| `workflow` | Modulo Erlang | Un file `.wfl` = un modulo `.beam` |
| `step` | Funzione + GenServer opzionale | Se stateful diventa GenServer |
| `parallel` | `spawn_link` + receive | Processi leggeri BEAM nativi |
| `sequence` | Chiamate in pipeline | Semplice composizione funzionale |
| `task` | Funzione o chiamata a modulo esterno | Punto di integrazione con codice Erlang/Elixir |
| `on_failure` | Supervisor + strategia compensazione | Pattern saga — rollback esplicito |
| `wait_for` | `receive ... after` | Timeout nativo BEAM |
| `correlate` | Process Registry / `gproc` | Correlazione tra istanze workflow |
| `emit` / `signal` | Message passing | `Pid ! {signal, Name, Payload}` |
| `state` | Variabile di stato passata tra step | Immutabile, passata esplicitamente |

---

### Modello di esecuzione

Ogni **istanza** di un workflow è un processo BEAM autonomo. Il parallelismo non è simulato — ogni ramo `parallel` lancia processi reali con `spawn_link`. Il supervisor tree viene generato automaticamente dal compilatore per ogni workflow che dichiara `on_failure`.

```
WorkflowSupervisor (generato)
├── StepProcess_1
├── StepProcess_2
│   ├── ParallelWorker_A
│   └── ParallelWorker_B
└── CompensationProcess (on_failure)
```

---

### CLI

Il compilatore sarà distribuito come **escript** — un binario autocontenuto che non richiede installazione di rebar3 per l'uso finale:

```bash
wfl compile order_processing.wfl      # produce order_processing.beam
wfl run    order_processing.wfl       # compila ed esegue
wfl check  order_processing.wfl       # solo validazione semantica
wfl inspect order_processing.wfl      # mostra AST e Erlang generato
```

---

### Decisioni architetturali aperte (da definire insieme)

Questi sono i punti su cui ti servirà darmi indicazioni precise prima di prototipare:

1. **Sintassi** — stile keyword-based (come sopra) o indentazione significativa? Blocchi con `do/end` o con `{}`?
2. **Tipi** — dinamico puro come Erlang, oppure annotazioni opzionali con dialyzer, oppure tipi statici obbligatori?
3. **Input/Output degli step** — passaggio di stato esplicito tra step o blackboard condiviso (come variabili di processo)?
4. **Gestione errori** — solo `on_failure` globale o anche `try/catch` inline per singolo task?
5. **Interop** — come si chiama codice Erlang/Elixir esterno da un workflow? Import espliciti o chiamata diretta `Module:function`?
6. **Concorrenza avanzata** — supporto a `wait_for` con timeout, `correlate` tra istanze diverse, o lo lasciamo fuori dalla v1?
7. **Distribuzione** — i processi generati devono poter girare su nodi BEAM remoti (`node@host`) o solo locale per la v1?

---

Quando mi dai le indicazioni su questi punti partiamo con implementazione ordinata modulo per modulo.
