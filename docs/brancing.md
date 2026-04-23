# Branching

Seagrass supporta branching composto usando `,` per il parallelo e `{ ... }`
per raggruppare un sotto-programma.

## Regole

- Un blocco `{ ... }` contiene statement Seagrass normali.
- Dentro un blocco, newline e `;` restano separatori sequenziali.
- Una virgola `,` mette in parallelo le espressioni sullo stesso livello.
- Un ramo parallelo puo' essere una singola call oppure un blocco annidato.

## Esempi

```seagrass
chiamata1(), {
    chiamata2()
    chiamata3()
}
```

`chiamata1()` gira in parallelo alla sequenza `chiamata2()` poi `chiamata3()`.

```seagrass
{
    chiamata1a()
    chiamata1b()
}, {
    chiamata2()
    chiamata3()
}
```

I due blocchi partono in parallelo; dentro ogni blocco le chiamate restano
sequenziali.

```seagrass
chiamata1(), {
    { chiamata2(); chiamata3() }, {
        chiamata4();
    }
}
```

Il secondo ramo e' un blocco che contiene a sua volta un parallelo tra due
sotto-rami: il primo e' una sequenza di due call, il secondo e' una call sola.
