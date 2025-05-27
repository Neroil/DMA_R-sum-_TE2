#import "@preview/summy:0.1.0": *

#set text(font: "Helvetica")
#set par(justify: true)

#show: cheatsheet.with(
  title: "Cheatsheet Title", 
  authors: "Authors",
  write-title: false,
  font-size: 7pt,
  line-skip: 7pt,
  x-margin: 15pt,
  y-margin: 15pt,
  num-columns: 4,
  column-gutter: 4pt,
  numbered-units: false,
)

// Les trois parties
#include "units/00-partie1.typ"
#include "units/01-partie2.typ"
#include "units/02-partie3.typ"

// Les exercices
#include "units/exercices/00-ex-codes-barres.typ"
#include "units/exercices/01-ex-NFC.typ"
#include "units/exercices/02-ex-capteurs.typ"
#include "units/exercices/03-ex-wearable.typ"
#include "units/exercices/04-ex-NTK.typ"

// Les labos
