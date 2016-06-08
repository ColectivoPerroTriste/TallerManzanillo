# Recreador.rb

## Índice

* [Descripción](#descripción)
* [Dependencias](#dependencias)
* [Uso](#uso)
* [Explicación](#explicación)

## Descripción

Este `script` recrea los archivos OPF, NCX y NAV. En sistemas UNIX
también crea o modifica el archivo EPUB.

## Dependencias

Este `script` requiere Ruby. [Véase aquí para instalar]
(https://www.ruby-lang.org/en/documentation/installation/#rubyinstaller). La
versión mínima de Ruby que se ha probado es la 1.9.3p484.

## Uso

###### 1. Desde el *shell* se ordena arrancar el `script` con `ruby RUTA/recreador.rb`.

Para mayor comodidad solo escribe en el *shell* `ruby ` [con un espacio al
final] y arrastra el archivo `recreador.rb`.

###### 2. Indica la carpeta donde están los archivos para el EPUB.

Se tiene que poner la ruta absoluta sin `~`, para mayor comodidad solo arrastra
la carpeta al *shell*.

###### 3. A continuación responde lo que se te pide.

*Si se crea por primera vez*. Para poder crear ciertos metadatos es necesario
indicar el título, el autor o editor principal, la editorial, la sinopsis, el
lenguaje, la versión, la portada (opcional), las secciones ocultas (opcionales)
o las que no aparecen en la tabla de contenidos (opcionales) así como el NAV
(`nav.xhtml` por defecto) de la obra.

    Se recomienda ampliamente indicar la portada, ya que así puede asignarse
    la miniatura que despliegan las bibliotecas digitales.

    Las secciones que no se ven en la tabla de contenidos están pensadas para
    solo mostrarse en el seguimiento lineal de la obra, útiles para información
    secundaria como portadillas o legales.

    Las secciones ocultas no se muestran en la lectura lineal de la obra ni
    en la tabla de contenidos, útiles para información terciaria como notas al
    pie o tablas.

    Para mayor flexibilidad, cabe la posibilidad de indicar algún nombre
    personalizado para el NAV.

*Si es una creación posterior*. Lo primero que se ha de responder es si se
desean conservar los metadatos existentes. Si se responde que sí, lo único que
se ha de volver a introducir es la versión de la obra. Si se responde que no,
se vuelven a pedir todos los metadatos, como si se crearan por primera vez. Por
defecto la respuesta es sí.

    Los metadatos existentes no excluyen la recreación de los archivos opf,
    ncx y nav. Solo evita el trabajo repetitivo de ingresar los metadatos.

    Siempre se pide la versión de la obra para permitir un control de
    versiones.

###### 4. ¡Es todo!

  * Desde el *shell* puedes leer cómo se recrean los siguientes archivos:
    * El archivo OPF.
    * El archivo NCX.
    * El archivo NAV.
    * El EPUB (solo para sitemas UNIX).

## Explicación

### Remedio a las tareas repetitivas

La mayoría de los archivos EPUB tienen similitudes en su estructura, lo cual
hace conveniente la utilización de plantillas. Si bien esto evita el problema
de crear la estructura desde cero, persisten las dificultades de rehacer el OPF,
el NCX y el NAV. En la gran mayoría de los casos, solo alguns metadatos
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

Mucha de esta información es reutilizada para la recreación del NCX y del NAV.
Además, para evitar volver a introducir la información cada vez que se recreen
los archivos, se guarda un archivo `.recreador-metadata` con esta información
en la raíz de los archivos para el EPUB que nunca se incluye en el EPUB.

    Si se utiliza una herramienta externa para crear el EPUB,
    se tiene que asegurar que no se incluya el archivo «.recreador-metadata».

    La manipulación directa del «.recreador-metadata» no ocasiona ningún
    conflicto.

### Recreación del NCX

Debido a su similitudes con el NAV, la recreación del NCX se da en paralelo con
el NAV. En un primer momento se excluyen todos los archivos que no sean XHTML,
o que se han escogido para no mostarse. Por último se obtiene una relación
entre el nombre del archivo y el título de ese documento.

    Todos los archivos se organizan alfabéticamente para evitar órdenes
    aleatorios.

    Para un óptimo resultado, todos los archivos XHTML que no sean el NAV han
    de estar en una misma carpeta.

    Los títulos de los archivos se extraen del contenido presente en la
    etiqueta <title>

### Recreación del NAV

Por su parecido con el NCX, la recreación del NAV es semejante a la del NCX. La
principal diferencia es la extracción de los números de página (si los hay).
Este paso adicional consiste en llevar a cabo una relación entre el nombre del
archivo con sus respectivas páginas, para luego pasar a agregarse al NAV.

    La estructura para los números de página, independientemente de su
    ubicación, ha de ser «epub:type="pagebreak" id="page1" title="1"».

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
  * `.recreador-metadata`. El archivo oculto que se crea o modifica para
  conservar algunos metadatos.
* `CARPETA-PARA-EPUB.epub`. El EPUB que se crea o se modifica.
