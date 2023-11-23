// PRODUCTOS
const productos = [
    // labiales
    {
        id: "labial-01",
        titulo: "Labial",
        imagen: "./img/labial.png",
        categoria: {
            nombre: "labiales",
            id: "labiales" //campo clave con HTML id enlace
        },
        precio: 5000
    },
    {
        id: "labial-02",
        titulo: "Labial ",
        imagen: "./img/labial2.png",
        categoria: {
            nombre: "labiales",
            id: "labiales" //tiene que ser igual siempre con el que tienes en html
        },
        precio: 5000
    },
    {
        id: "labial-03",
        titulo: "Labial",
        imagen: "./img/labial3.png",
        categoria: {
            nombre: "labial",
            id: "labiales"
        },
        precio: 6000
    },
    {
        id: "labial-04",
        titulo: "labial cremoso",
        imagen: "./img/labial4.jpg",
        categoria: {
            nombre: "labiales",
            id: "labiales"
        },
        precio: 6000
    },
    {
        id: "labial-05",
        titulo: "Labial cremoso",
        imagen: "./img/labial5.png",
        categoria: {
            nombre: "labiales",
            id: "labiales"
        },
        precio: 6000
    },
    {
        id: "labial-06",
        titulo: "Labial cremoso",
        imagen: "./img/labial6.png",
        categoria: {
            nombre: "labiales",
            id: "labiales"
        },
        precio: 6000
    },
    {
        id: "labial-07",
        titulo: "Labial humectante",
        imagen: "./img/aceite-labial.jpg",
        categoria: {
            nombre: "labiales",
            id: "labiales"
        },
        precio: 6000
    },
    //mascara de pestañas
    {
        id: "mascara-01",
        titulo: "Mascara de pestaña",
        imagen: "./img/mascara-de-pestanas.jpg",
        categoria: {
            nombre: "mascaras",
            id: "mascaras" //campo clave HTML
        },
        precio: 15000
    },
    {
        id: "mascara-02",
        titulo: "Mascara de pestaña",
        imagen: "./img/mascara01.jpg",
        categoria: {
            nombre: "mascaras",
            id: "mascaras" //campo clave HTML
        },
        precio: 15000
    },
    {
        id: "mascara-03",
        titulo: "Mascara de pestaña",
        imagen: "./img/mascara2.png",
        categoria: {
            nombre: "mascaras",
            id: "mascaras" //campo clave HTML
        },
        precio: 15000
    },
    {
        id: "mascara-03",
        titulo: "Mascara de pestaña",
        imagen: "./img/mascara4.jpg",
        categoria: {
            nombre: "mascaras",
            id: "mascaras" //campo clave HTML
        },
        precio: 15000
    },

    // sombras
    {
        id: "sombras-01",
        titulo: "sombra",
        imagen: "./img/ojos2.JPG",
        categoria: {
            nombre: "sombra",
            id: "sombras" //campo clave
        },
        precio: 20000
    },
    {
        id: "sombras-02",
        titulo: "sombra",
        imagen: "./img/ojos1.png",
        categoria: {
            nombre: "sombra",
            id: "sombras" //campo clave
        },
        precio: 20000
    },
    {
        id: "sombras-03",
        titulo: "sombra",
        imagen: "./img/ojos4.JPG",
        categoria: {
            nombre: "sombra",
            id: "sombras" //campo clave
        },
        precio: 20000
    },
    {
        id: "sombras-01",
        titulo: "sombra",
        imagen: "./img/ojos3.webp",
        categoria: {
            nombre: "sombra",
            id: "sombras" //campo clave
        },
        precio: 20000
    },
     // lapiz
     {
        id: "lapiz-01",
        titulo: "Lapiz",
        imagen: "./img/lapiz1.JPG",
        categoria: {
            nombre: "lapiz",
            id: "lapiz" //campo clave
        },
        precio: 5000
    },
    {
        id: "lapiz-02",
        titulo: "Lapiz",
        imagen: "./img/lapiz6.png",
        categoria: {
            nombre: "lapiz",
            id: "lapiz" //campo clave
        },
        precio: 5000
    },
    {
        id: "lapiz-01",
        titulo: "Lapiz",
        imagen: "./img/lapiz5.JPG",
        categoria: {
            nombre: "lapiz",
            id: "lapiz" //campo clave
        },
        precio: 5000
    },
    {
        id: "lapiz-01",
        titulo: "Lapiz",
        imagen: "./img/lapiz4.JPG",
        categoria: {
            nombre: "lapiz",
            id: "lapiz" //campo clave
        },
        precio: 5000
    },
    {
        id: "lapiz-01",
        titulo: "Lapiz",
        imagen: "./img/lapiz3.png",
        categoria: {
            nombre: "lapiz",
            id: "lapiz" //campo clave
        },
        precio: 5000
    },
];

const contenedorProductos = document.querySelector("#contenedor-productos");
const botonesCategorias = document.querySelectorAll(".boton-categoria");
const tituloPrincipal = document.querySelector("#titulo-principal");
let botonesAgregar = document.querySelectorAll(".producto-agregar");
const numerito = document.querySelector("#numerito");

function cargarProductos(productosElegidos) {

    contenedorProductos.innerHTML = "";

    productosElegidos.forEach(producto => {

        const div = document.createElement("div");
        div.classList.add("producto");
        div.innerHTML = `
            <img class="producto-imagen" src="${producto.imagen}" alt="${producto.titulo}">
            <div class="producto-detalles">
                <h3 class="producto-titulo">${producto.titulo}</h3>
                <p class="producto-precio">$${producto.precio}</p>
                <button class="producto-agregar" id="${producto.id}">Agregar</button>
            </div>
        `;

        contenedorProductos.append(div);
    })

    actualizarBotonesAgregar();
}

cargarProductos(productos);

botonesCategorias.forEach(boton => {
    boton.addEventListener("click", (e) => {

        botonesCategorias.forEach(boton => boton.classList.remove("active"));
        e.currentTarget.classList.add("active");

        if (e.currentTarget.id != "todos") {
            const productoCategoria = productos.find(producto => producto.categoria.id === e.currentTarget.id);
            tituloPrincipal.innerText = productoCategoria.categoria.nombre;
            const productosBoton = productos.filter(producto => producto.categoria.id === e.currentTarget.id);
            cargarProductos(productosBoton);
        } else {
            tituloPrincipal.innerText = "Todos los productos";
            cargarProductos(productos);
        }

    })
});

function actualizarBotonesAgregar() {
    botonesAgregar = document.querySelectorAll(".producto-agregar");

    botonesAgregar.forEach(boton => {
        boton.addEventListener("click", agregarAlCarrito);
    });
}

let productosEnCarrito;

let productosEnCarritoLS = localStorage.getItem("productos-en-carrito");

if (productosEnCarritoLS) {
    productosEnCarrito = JSON.parse(productosEnCarritoLS);
    actualizarNumerito();
} else {
    productosEnCarrito = [];
}

function agregarAlCarrito(e) {
    const idBoton = e.currentTarget.id;
    const productoAgregado = productos.find(producto => producto.id === idBoton);

    if(productosEnCarrito.some(producto => producto.id === idBoton)) {
        const index = productosEnCarrito.findIndex(producto => producto.id === idBoton);
        productosEnCarrito[index].cantidad++;
    } else {
        productoAgregado.cantidad = 1;
        productosEnCarrito.push(productoAgregado);
    }

    actualizarNumerito();

    localStorage.setItem("productos-en-carrito", JSON.stringify(productosEnCarrito));
}

function actualizarNumerito() {
    let nuevoNumerito = productosEnCarrito.reduce((acc, producto) => acc + producto.cantidad, 0);
    numerito.innerText = nuevoNumerito;
}