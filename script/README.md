# Hacedor.rb

## Índice

* [Descripción](#descripción)
* [Dependencias](#dependencias)
* [Uso](#uso)
* [Explicación](#explicación)

## Descripción

Este `script` recrea los archivos OPF, NCX y `nav.xhtml`. En sistemas UNIX
también crea o modifica el archivo EPUB.

## Dependencias

Este script requiere Ruby versión 2. [Véase aquí para instalar]
(https://www.ruby-lang.org/en/documentation/installation/#rubyinstaller).

## Uso

###### 1. Desde el *shell* se ordena arrancar el script con `ruby RUTA/hacedor.rb`.
  * Para mayor comodidad solo escribe en el *shell* `ruby ` [con un espacio al
  final] y arrastra el archivo `hacedor.rb`.

###### 2. Indica la carpeta donde están los archivos para el EPUB.
  * Se tiene que poner la ruta absoluta sin `~`, para mayor comodidad solo
  arrastra la carpeta al *shell*.

###### 3. A continuación responde lo que se te pide.
  * *Si se crea por primera vez*. Para poder crear ciertos metadatos es
  necesario indicar el título, el autor o editor principal, la editorial, la
  sinopsis, el lenguaje, la versión, la portada (opcional) y las secciones
  ocultas de la obra (opcionales).
    * Aunque opcional, es ampliamente recomendable indicar cuál es la portada
    de la obra, ya que de esta manera es posible indicar cuál imagen se ha de
    renderizar en la biblioteca digital donde quizá se aloje el libro.

    * Las secciones ocultas no se muestran en la lectura lineal de la obra ni
    en el índice. Estas propiedades están pensadas para notas al pie, tablas o
    demás información adicional que se considera secundaria. Por defecto no hay
    secciones ocultas.
  * *Si es una creación posterior*. Lo primero que se ha de responder es si se
  desean conservar los metadatos existentes. Si se responde que sí, lo único
  que se ha de volver a introducir es la versión de la obra. Si se responde que
  no, se vuelven a pedir todos los metadatos, como si se crearan por primera
  vez. Por defecto la respuesta es sí.
    * Los metadatos existentes solo incluyen el título, el autor o editor
    principal, la editorial, la sinopsis, el lenguaje, la portada (opcional) y
    las secciones ocultas de la obra. *El resto de la información se vuelve a
    generar*

    * Siempre se pide la versión de la obra para posibilidad un control de
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
el NCX y el `nav.xhtml`. En la gran mayoría de los casos, solo los metadatos
requieren de una intervención directa. Ante esta problemática, este script está
pensado para automatizar la serie de tareas monótonas para disminuir los
tiempos de desarrollo.

Para evitar la recreación en carpetas potencialmente conflictivas, el script
solo arranca si se encuentra en la carpeta raíz del futuro EPUB, al localizar
el archivo `mimetype` en esta raíz.

### Recreación del OPF

El OPF comprende tres partes: los metadatos, el manifiesto y la espina. En los
metadatos indicamos la información sobre el archivo (el título de la obra, por
ejemplo). En el manifiesto se indican todos los archivos que contienen el EPUB.
En la espina se indica el orden de lectura del libro.

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
que se recreen los archivos, se guarda un archivo `.hacedor-metadata` con esta
información en la carpeta padre de la raíz de los archivos para el EPUB.

### Recreación del NCX

### Recreación del `nav.xhtml`

### Creación o modificación del EPUB

Para que Ruby tenga la posibilidad de trabajar con archivos comprimidos es
necesaria la instalación de una gema. Con el fin de no complicar la instalación,
se ha tomado la decisión de prescindir de ella. Por ello es que la creación o
modificación del EPUB se hace a partir de un llamado al *shell* mediante Ruby.

El EPUB se crea en la carpeta padre de la raíz de los archivos para el EPUB.
