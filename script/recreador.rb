# encoding: utf-8

# Obtiene el tipo de sistema operativo; viene de: http://stackoverflow.com/questions/170956/how-can-i-find-which-operating-system-my-ruby-program-is-running-on
module OS
    def OS.windows?
        (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end
    def OS.mac?
        (/darwin/ =~ RUBY_PLATFORM) != nil
    end
    def OS.unix?
        !OS.windows?
    end
    def OS.linux?
        OS.unix? and not OS.mac?
    end
end

# Elementos comunes de lo que se imprime
$blanco = ' [dejar en blanco para ignorar o terminar]:'
$necesario = ' [campo necesario]:'

# Elemento común para crear los archivos
$carpeta = ''
$primerosArchivos = Array.new

# Ayuda a crear el uid del libro
nombreLibro = ''
identificadorLibro = ''

# Identifica el nav
$nav = ''

# Inicio
puts "\nEste script recrea los archivos opf, ncx y nav."
puts "En sistemas UNIX también crea o modifica el archivo EPUB."

# Enmienda ciertos problemas con la línea de texto
def ArregloRuta (elemento)
    if elemento[-1] == ' '
        elemento = elemento[0...-1]
    end
    elementoFinal = elemento.gsub('\ ', ' ').gsub('\'', '') # Probablemente necesite modificación para Windows
    return elementoFinal
end

# Determina si en la carpeta hay un EPUB
def carpetaBusqueda
    puts "\nArrastra la carpeta donde están los archivos para el EPUB."
    $carpeta = gets.chomp

    $carpeta = ArregloRuta $carpeta

    # Se parte del supuesto de que la carpeta no es para un EPUB
    epub = false

    # Si no se da una línea vacía
    if $carpeta != ''
        # Si dentro de los directorios hay un opf, entonces se supone que hay archivos para un EPUB
        Dir.glob($carpeta + '/**') do |archivo|
            if File.basename(archivo) == "mimetype"
                epub = true
            else
                # Sirve para la creación del EPUB
                $primerosArchivos.push(File.basename(archivo))
            end
        end

        # Ofrece un resultado
        if epub == false
            puts "\nAl parecer en la carpeta seleccionada no es proyecto para un EPUB."
            carpetaBusqueda
        end
    else
        puts "\nNo se ingresó una ruta válida."
        carpetaBusqueda
    end
end

# Obtiene la carpeta de los archivos del EPUB
carpetaBusqueda

# Se obtiene la ruta para el EPUB
ruta = $carpeta.split("/")
rutaPadre = ''
ruta.each do |parte|
    if parte != ruta.last
        if parte != ruta.first
            rutaPadre += '/' + parte
        else
            rutaPadre += parte
        end
    end
end

rutaPadre = ArregloRuta rutaPadre

# Verifica si existe un archivo oculto de metadatos
Dir.chdir(rutaPadre)

metadatosPreexistentes = false
$metadatoPreexistenteNombre = ".recreador-metadata"

Dir.glob(rutaPadre + '/.*') do |archivo|
    if File.basename(archivo) == $metadatoPreexistenteNombre
        metadatosPreexistentes = true
    end
end

# Ayuda para la creación u obtención de los metadatos
$metadatosInicial = Array.new
$archivosNoLineales = Array.new
$portada = ''

# Crea un array para definir los archivos metadatos
def Metadatos (texto, dc)
    puts texto + $necesario
    metadato = gets.chomp
    coletilla = "@" + dc
    if metadato != ""
        $metadatosInicial.push(metadato + coletilla)
    else
        Metadatos texto, dc
    end
end

# Obtiene todos los metadatos
def metadatosTodo

    # Obtiene los metadatos
    Metadatos "\nTítulo", "dc:title"
    Metadatos "\nNombre del autor o editor principal (ejemplo: Apellido, Nombre)", "dc:creator"
    Metadatos "\nEditorial", "dc:publisher"
    Metadatos "\nSinopsis", "dc:description"
    Metadatos "\nLenguaje (ejemplo: es)", "dc:language"
    Metadatos "\nVersión (ejemplo: 1.0.0)", "dc:identifier"

    # Asigna el nombre de la portada para ponerle su atributo
    puts "\nNombre de la portada (ejemplo: portada.jpg)" + $blanco
    $portada = gets.chomp

    if $portada == ''
        $portada = ' '
    end

    # Crea un array para definir los archivos XHTML ocultos
    def noLineal
        puts "\nNombre del archivo XHTML sin su extensión" + $blanco
        archivoOculto = gets.chomp
        if archivoOculto != ""
            $archivosNoLineales.push(archivoOculto)
            noLineal
        end
    end

    # Determina si es necesario definir archivos ocultos
    def noLinealRespuesta
        puts "\n¿Existen archivos XHTML que se desean ocultar? [y/N]:"
        respuesta = gets.chomp.downcase
        if (respuesta != "")
            if (respuesta != "n")
                if (respuesta == "y")
                    noLineal
                else
                    noLinealRespuesta
                end
            end
        end
    end

    # Obtiene los archivos ocultos
    noLinealRespuesta

    # Obtiene ciertos nombres de archivos necesarios
    def ElementosNombre (elemento, elementoNombre, porDefecto)
        elemento = porDefecto
        puts "\nIndica el nombre del " + elementoNombre + " [" + porDefecto + " por defecto]:"
        elementoPosible = gets.chomp

        if elementoPosible.gsub(' ', '') == ''
            return elemento
        else
            if elementoPosible.split(".")[-1] == "xhtml"
                elemento = elementoPosible
                return elemento
            else
                puts "\nNombre no válido."
                ElementosNombre elemento, elementoNombre, porDefecto
            end
        end
    end

    $nav = ElementosNombre $nav, 'nav', 'nav.xhtml'

    # Ayuda a la creación u obtención de metadatos
    $archivosNoLineales.push(' ')

    # Crea el archivo oculto con metadatos
    archivoMetadatos = File.new(".recreador-metadata", "w")

    $metadatosInicial.each do |mI|
        archivoMetadatos.puts "_M_" + mI
    end

    $archivosNoLineales.each do |aN|
        archivoMetadatos.puts "_O_" + aN
    end

    archivoMetadatos.puts "_P_" + $portada.to_s

    archivoMetadatos.puts "_N_" + $nav.to_s

    archivoMetadatos.close
end

# Continúa con la petición de información adicional
puts "\n"
puts "\nResponde lo siguiente"

# Si existen metadatos
if metadatosPreexistentes == true
    $respuestaMetadatos = ''

    # Pregunta sobre la pertinencia de reutilizar los metadatos
    def preguntaMetadatos
        puts "\nSe han encontrado metadatos preexistentes, ¿deseas conservarlos? [Y/n]:"
        $respuestaMetadatos = gets.chomp.downcase

        if $respuestaMetadatos == '' or $respuestaMetadatos == 'y'
            reutilizacionMetadatos
        elsif $respuestaMetadatos == 'n'
            metadatosTodo
        else
            preguntaMetadatos
        end
    end

    # Reutiliza los metadatos
    def reutilizacionMetadatos
        metadatoPreexistente = File.open($metadatoPreexistenteNombre)
        metadatoPreexistente.each do |linea|
            lineaCortaInicio = linea[0...3]
            lineaCortaFinal = linea[3...-1]

            # Permite separar los metadatos según su tipo
            if lineaCortaInicio == "_M_"
                # Evita copiar la versión
                if linea[-11...-1] != "identifier"
                    $metadatosInicial.push(lineaCortaFinal)
                end
            elsif lineaCortaInicio == "_O_"
                $archivosNoLineales.push(lineaCortaFinal)
            elsif lineaCortaInicio == "_P_"
                $portada = lineaCortaFinal
            elsif lineaCortaInicio == "_N_"
                $nav = lineaCortaFinal
            end
        end

        # Pregunta de nuevo por la versión
        Metadatos "\nVersión (ejemplo: 1.0.0)", "dc:identifier"
    end

    preguntaMetadatos
# Si no existen metadatos, los pide
else
    metadatosTodo
end

# Sirve para añadir elementos
indice = 0

# Para obtener elementos constantes en el opf, el ncx y el nav
rutaAbsoluta = Array.new
rutaRelativa = Array.new
rutaComun = ''
nombreOpf = ''
identificadorNcx = ''

# Obtiene las rutas absolutas
Dir.glob($carpeta + '/**/*.*') do |archivo|
    # Los únicos dos archivos que no se necesitan es el container.xml y el opf
    if File.extname(archivo) != '.xml' and File.extname(archivo) != '.opf'
        rutaAbsoluta.push(archivo)
        if File.extname(archivo) == '.ncx'
            identificadorNcx = File.basename(archivo)
        end
        if File.basename(archivo) == $nav
            $nav = File.basename(archivo)
        end
    elsif File.extname(archivo) == '.opf'
        nombreOpf = File.basename(archivo)
    end
end

# Crea otro conjunto que servirá para las rutas relativas
Dir.glob($carpeta + '/**/*.*') do |archivoCorto|
    if File.extname(archivoCorto) != '.xml' and File.extname(archivoCorto) != '.opf'
        rutaRelativa.push(archivoCorto)
    # Obtiene la ruta común de los archivos
    elsif File.extname(archivoCorto) == '.opf'
        rutaComun = archivoCorto
        rutaComun[File.basename(archivoCorto)] = ''
    end
end

# Sustituye la ruta común por nada
rutaRelativa.each do |elemento|
    elemento[rutaComun] = ''
end

# Para recrear el opf
metadatos = Array.new
manifiesto = Array.new
espina = Array.new

# Inicia la creación de los metadatos
metadatos.push('    <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">')

# Añade cada uno de los metadatos
$metadatosInicial.each do |dc|
    conjunto = dc.split('@')
    uid = ''
    if conjunto[0] != 'NA'
        if conjunto[1] == 'dc:title'
            nombreLibro = conjunto[0]
        elsif conjunto[1] == 'dc:identifier'
            uid = ' id="uid"'
            identificadorLibro = nombreLibro + '-'+ conjunto[0]
            conjunto[0] = identificadorLibro
        end
        metadatos.push('        <' + conjunto[1] + uid + '>' + conjunto[0] + '</' + conjunto[1] + '>')
    end
end

# Ajusta el tiempo para que siempre sean dos cifras
def Ajuste (numero)
    cantidad = ''
    if numero < 10
        cantidad = '0' + numero.to_s
    else
        cantidad = numero.to_s
    end
    return cantidad
end

# Obtiene el tiempo actual
fecha = Time.new

# Ajusta las cifras
ano = Ajuste fecha.year
mes = Ajuste fecha.month
dia = Ajuste fecha.day
hora = Ajuste fecha.hour
minuto = Ajuste fecha.min
segundo = Ajuste fecha.sec

# Crea la fecha completa
fechaCompleta =  ano + '-' + mes + '-' + dia + 'T' + hora + ':' + minuto + ':' + segundo + 'Z'

# Termina los metadatos
metadatos.push('        <meta property="dcterms:modified">' + fechaCompleta + '</meta>')
metadatos.push('        <meta property="rendition:layout">reflowable</meta>')
metadatos.push('        <meta property="ibooks:specified-fonts">true</meta>')
metadatos.push('    </metadata>')

# Acomoda el identificador del ncx
identificadorNcx['.'] = '_'
identificadorNcx = 'id_' + identificadorNcx

# Identifica los tipos de recursos existentes en el opf según su tipo de extensión
def Tipo (extension)
    if extension == '.xhtml'
        return 'application/xhtml+xml'
    elsif extension == '.ttf'
        return 'application/vnd.ms-opentype'
    elsif extension == '.ncx'
        return 'application/x-dtbncx+xml'
    elsif extension == '.jpg' or extension == '.jpeg'
        return 'image/jpeg'
    elsif extension == '.png'
        return 'image/png'
    elsif extension == '.svg'
        return 'image/svg+xml'
    elsif extension == '.css'
        return 'text/css'
    end
end

# Determina si se le pone un atributo no lienal al XHTML
def NoLinealCotejo (identificador)
    retorno = ""
    $archivosNoLineales.each do |comparar|
        comparador = "id_" + comparar + "_xhtml"
        if comparador == identificador
            retorno = ' linear="no"'
            break
        end
    end
    return retorno
end

def Propiedad (archivo, comparacion, propiedad)
    propiedadAdicion = ''
    if archivo == comparacion
        propiedadAdicion = ' properties="' + propiedad + '"'
    end
    return propiedadAdicion
end

# Recorre todos los archivos en busca de los recursos para el manifiesto y la espina
Dir.glob($carpeta + '/**/*.*') do |archivoManifiesto|
    if File.extname(archivoManifiesto) != '.xml' and File.extname(archivoManifiesto) != '.opf'

        # Crea el identificador
        identificador = File.basename(archivoManifiesto)
        identificador['.'] = '_'
        identificador = 'id_' + identificador

        # Añade el tipo de recurso
        tipo = Tipo File.extname(archivoManifiesto)

        # Añade propiedades
        propiedad = Propiedad File.basename(archivoManifiesto), $portada, 'cover-image'
        propiedad2 = Propiedad File.basename(archivoManifiesto), $nav, 'nav'

        # Añade la propiedad no lineal, si la hay
        noLineal = NoLinealCotejo identificador

        # Agrega los elementos al manifiesto
        manifiesto.push('        <item href="' + rutaRelativa[indice] + '" id="' + identificador + '" media-type="' + tipo.to_s + '"' + propiedad.to_s + propiedad2.to_s + ' />')

        # Agrega los elementos a la espina
        if File.extname(archivoManifiesto) == '.xhtml' and File.basename(archivoManifiesto) != $nav
            espina.push ('        <itemref idref="' + identificador + '"' + noLineal.to_s + '/>')
        end

        # Permite recurrir a la ruta relativa
        indice += 1
    end
end

# Acomoda los elementos alfabéticamente
manifiesto = manifiesto.sort
espina = espina.sort

# Para el inicio del manifiesto y de la espina
manifiesto.insert(0, '    <manifest>')
espina.insert(0, '    <spine toc="' + identificadorNcx + '">')

# Para el fin del manifiesto y de la espina
manifiesto.push('    </manifest>')
espina.push('    </spine>')

indice = 0

Dir.glob($carpeta + '/**/*.*') do |archivo|
    if File.extname(archivo) == '.opf'
        # Inicia la recreación del opf
        puts "\nRecreando el " + File.basename(archivo) + "..."

        # Abre el opf
        opf = File.open(archivo, 'w')

        # Añade los primeros elementos necesarios
        opf.puts '<?xml version="1.0" encoding="UTF-8"?>'
        opf.puts '<package xmlns="http://www.idpf.org/2007/opf" xml:lang="en" unique-identifier="uid" prefix="ibooks: http://vocabulary.itunes.apple.com/rdf/ibooks/vocabulary-extensions-1.0/" version="3.0">'

        # Añade los metadatos
        metadatos.each do |lineaMetadatos|
            opf.puts lineaMetadatos
        end

        # Añade el manifiesto
        manifiesto.each do |lineaManifiesto|
            opf.puts lineaManifiesto
        end

        # Añade la espina
        espina.each do |lineaEspina|
            opf.puts lineaEspina
        end

        # Añade el último elemento necesario
        opf.puts '</package>'

        # Termina el opf
        opf.close
    end
end

# Para empezar a recrear el ncx y el nav
$archivosTocs = Array.new
$divisor = '/'              # Probablemente necesite modificación para Windows
$coletillaXhtml = ''
$coletillaNav = ''
$coletillaNcx = ''

# Para sacar el nivel en que se encuentran
rutaRelativa.each do |coletillaObtencion|
    if File.extname(coletillaObtencion) == '.xhtml'
        if File.basename(coletillaObtencion) != $nav
            $coletillaXhtml = coletillaObtencion.split($divisor)
        else
            $coletillaNav = coletillaObtencion.split($divisor)
        end
    else
        if File.extname(coletillaObtencion) == '.ncx'
            $coletillaNcx = coletillaObtencion.split($divisor)
        end
    end
end

# A partir de la cantidad de nieveles contenidos, se recrean las coletillas de los archivos
def CreadorColetillas (coletilla)
    coletillaFinal = ''

    # La coletilla queda vacía suponiendo que solo exista un nivel
    if coletilla.length > 1

        # Se itera si exista más de un nivel
        coletilla.each do |coletillas|

            # Se ignora el último nivel porque es el nombre del archivo
            if coletillas != coletilla[-1]

                # Si se trata de la coletilla de los XHTML se ponen los nombres correspondientes a los niveles superiores
                if coletilla == $coletillaXhtml
                    coletillaFinal += coletillas.to_s + $divisor
                # Si se trata del ncx o el nav cada nivel superior es igual a dos puntos suspensivos
                else
                    coletillaFinal += '..' + $divisor
                end
            end
        end
    end

    # Regresa el valor obtenido
    return coletillaFinal
end

# Saca las coletillas correspondientes
$coletillaNcx = CreadorColetillas $coletillaNcx
$coletillaNav = CreadorColetillas $coletillaNav
$coletillaXhtml = CreadorColetillas $coletillaXhtml

# Para sacar una ruta semejante a la rutaRelativa
$archivosNoLinealesCompleto = Array.new

$archivosNoLineales.each do |elementoNL|
    if elementoNL != ' '
        $archivosNoLinealesCompleto.push($coletillaXhtml + elementoNL + '.xhtml')
    end
end

rutaRelativa.each do |rr|
    if File.extname(rr) == '.xhtml' and File.basename(rr) != $nav
        $archivosTocs.push(rr)
    end
end

$archivosTocs.each do |at|
    $archivosNoLinealesCompleto.each do |nlc|
        if at == nlc
            $archivosTocs.delete(at)
            break
        end
    end
end

$archivosTocs = $archivosTocs.sort

puts $archivosTocs

#
# # Va a la carpeta del EPUB para tener posibilidad de crearlo
# Dir.chdir($carpeta)
#
# # Fin
# mensajeFinal = "\nEl proceso ha terminado."
#
# if OS.unix?
#     puts "\nCreando EPUB..."
#
#     # Crea la ruta para el EPUB
#     rutaEPUB = "../#{ruta.last}.epub"
#
#     # Crea el EPUB
#     system ("zip #{rutaEPUB} -X mimetype")
#     system ("zip #{rutaEPUB} -r #{$primerosArchivos[-2]} #{$primerosArchivos[-1]} -x \*.DS_Store")
#
#     # Finaliza la creación
#     puts "\n#{ruta.last}.epub creado en: #{rutaPadre}"
#     puts mensajeFinal
# else
#     puts mensajeFinal + " Solo es necesario comprimir en formato EPUB."
# end
