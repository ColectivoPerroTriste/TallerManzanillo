# Recreador.rb

## Índice

* [Descripción](#descripción)
* [Dependencias](#dependencias)
* [Uso](#uso)
* [Explicación](#explicación)

## Descripción

Este `script` recrea los archivos OPF, NCX y `nav.xhtml`. En sistemas UNIX
también crea o modifica el archivo EPUB.

## Dependencias

Este `script` requiere Ruby. [Véase aquí para instalar]
(https://www.ruby-lang.org/en/documentation/installation/#rubyinstaller). La
versión mínima de Ruby que se ha probado es la 1.9.3p484.

## Uso

###### 1. Desde el *shell* se ordena arrancar el `script` con `ruby RUTA/recreador.rb`.

  * Para mayor comodidad solo escribe en el *shell* `ruby ` [con un espacio al
  final] y arrastra el archivo `recreador.rb`.

###### 2. Indica la carpeta donde están los archivos para el EPUB.

  * Se tiene que poner la ruta absoluta sin `~`, para mayor comodidad solo
  arrastra la carpeta al *shell*.

###### 3. A continuación responde lo que se te pide.

  * *Si se crea por primera vez*. Para poder crear ciertos metadatos es
  necesario indicar el título, el autor o editor principal, la editorial, la
  sinopsis, el lenguaje, la versión, la portada (opcional), las secciones
  ocultas (opcionales) o las que no aparecen en la tabla de contenidos
  (opcionales) así como la navegación (`nav.xhtml` por defecto) de la obra.
    * Aunque opcional, es ampliamente recomendable indicar cuál es la portada
    de la obra, ya que de esta manera es posible indicar cuál imagen se ha de
    renderizar en la biblioteca digital donde quizá se aloje el libro.

    * Las secciones ocultas no se muestran en la lectura lineal de la obra ni
    en la tabla de contenidos. Estas propiedades están pensadas para notas al
    pie, tablas o demás información adicional que se considera secundaria. Por
    defecto no hay secciones ocultas.

    * Las secciones que no se ven en la tabla de contenidos están pensadas para
    secciones del libro que no se quieren mostrar ahí, pero que sí se desea que
    formen parte de la lectura lineal de la obra, como pueden ser las
    portadillas o la legal. Por defecto todas las secciones que no estén
    ocultas se muestran en la tabla de contenidos.

    * Para permitir más libertad, cabe la posibilidad de indicar algún nombre
    personalizado para la navegación, pese a que en la mayoría de los casos sea
    «nav.xhtml».
  * *Si es una creación posterior*. Lo primero que se ha de responder es si se
  desean conservar los metadatos existentes. Si se responde que sí, lo único
  que se ha de volver a introducir es la versión de la obra. Si se responde que
  no, se vuelven a pedir todos los metadatos, como si se crearan por primera
  vez. Por defecto la respuesta es sí.
    * Los metadatos existentes solo incluyen el título, el autor o editor
    principal, la editorial, la sinopsis, el lenguaje, la portada (opcional) y
    las secciones ocultas de la obra. El resto de la información se vuelve a
    generar.

    * Siempre se pide la versión de la obra para permitir un control de
    versiones.

###### 4. ¡Es todo!

  * Desde el *shell* puedes leer cómo se recrean los siguientes archivos:
    * El archivo OPF.
    * El archivo NCX.
    * El `nav.xhtml`.
    * El EPUB (solo para sitemas UNIX).

## Explicación

### Remedio a las tareas repetitivas

La mayoría de los archivos EPUB tienen similitudes en su estructura, lo cual
hace conveniente la utilización de plantillas. Si bien esto evita el problema
de crear la estructura desde cero, persisten las dificultades de rehacer el OPF,
el NCX y el `nav.xhtml`. En la gran mayoría de los casos, solo alguns metadatos
requieren de una intervención directa. Ante esta problemática, este `script`
está pensado para automatizar la serie de tareas monótonas para disminuir los
tiempos de desarrollo y aumentar los ratos de ocio. (;

Para evitar la recreación en carpetas potencialmente conflictivas, el `script`
solo arranca si se encuentra en la carpeta raíz del futuro EPUB, al localizar
el archivo `mimetype`.

### Recreación del OPF

El OPF comprende tres partes: los metadatos, el manifiesto y la espina. En los
metadatos indicamos la información sobre el archivo (el título de la obra, por
ejemplo). En el manifiesto referimos todos los archivos que contienen el EPUB.
En la espina determinamos el orden de lectura del libro.

La recreación de este archivo involucra tres etapas para cada una de estas
partes. La primera, la recreación de los metadatos, involucra cierta
interveción directa mediante la obtención de información por parte de quien lo
usa (existen ciertos metadatos que no requieren de intervención directa, como
la fecha de creación). El resto de las partes obtienen su información a partir
de los archivos presentes para el EPUB, gracias a esto es posible crear
identificadores, obtener los tipos de medios así como la adición de propiedades
(como la que indica cuál es la portada o cuáles archivos no forman parte de
la lectura lineal).

Mucha de esta información es reutilizada para la recreación del NCX y del
`nav.xhtml`. Además, para evitar volver a introducir la información cada vez
que se recreen los archivos, se guarda un archivo `.recreador-metadata` con esta
información en la carpeta padre de la raíz de los archivos para el EPUB.

### Recreación del NCX

**En desarrollo.**

### Recreación del `nav.xhtml`

**En desarrollo.**

### Creación o modificación del EPUB

Para que Ruby tenga la posibilidad de trabajar con archivos comprimidos, como
es el caso de los archivos EPUB, es necesaria la instalación de una gema. Con
el fin de no complicar la instalación, se ha tomado la decisión de prescindir
de ella. Por ello es que la creación o modificación del EPUB se hace a partir
de un llamado al *shell* mediante Ruby.

El EPUB se crea en la carpeta padre de la raíz de los archivos para el EPUB.

### Árbol de archivos creados

* `CARPETA-PARA-EPUB`. La carpeta para el EPUB en cuya raíz está presente el
`mimetype`.
* `.recreador-metadata`. El archivo oculto que se crea o modifica para conservar
algunos metadatos.
* `CARPETA-PARA-EPUB.epub`. El EPUB que se crea o se modifica.
