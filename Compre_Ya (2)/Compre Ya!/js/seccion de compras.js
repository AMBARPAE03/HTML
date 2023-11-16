// PRODUCTOS
const productos = [
    //GRANOS
    {
        id: "GRANO-01",
        titulo: "ARVEJA",
        imagen: "../images/productos/arveja.png",//FOTO
        categoria: {
            nombre: "Grano",
            id: "Grano"
        },
        precio: 4500
    },
    {
        id: "GRANO-02",
        titulo: "FRIJOL",
        imagen: "../images/productos/frijol.png",//FOTO
        categoria: {
            nombre: "Grano",
            id: "Grano"
        },
        precio: 7000
    },
    {
        id: "GRANO-03",
        titulo: "LENTEJA",
        imagen: "../images/productos/Lenteja.jpg",//FOTO
        categoria: {
            nombre: "Grano",
            id: "Grano"
        },
        precio: 6500
    },
    {
        id: "GRANO-04",
        titulo: "GARBANZO",
        imagen: "../images/productos/garbanzo.png",//FOTO
        categoria: {
            nombre: "Grano",
            id: "Grano"
        },
        precio: 4900
    },
    {
        id: "GRANO-05",
        titulo: "ARROZ",
        imagen: "../images/productos/Arroz-Diana.png",//FOTO
        categoria: {
            nombre: "Grano",
            id: "Grano"
        },
        precio: 2600
    },
    //FRUTAS
    {
        id: "Fruta-01",
        titulo: "Manzana",
        imagen: "../images/productos/manzana 1.png",//FOTO
        categoria: {
            nombre: "Fruta",
            id: "Fruta"
        },
        precio: 1500
    },
    {
        id: "Fruta-02",
        titulo: "Naranja",
        imagen: "../images/productos/naranja.jpeg",//FOTO
        categoria: {
            nombre: "Fruta",
            id: "Fruta"
        },
        precio: 2000
    },
    {
        id: "Fruta-03",
        titulo: "Uva",
        imagen: "../images/productos/uva.jpeg",//FOTO
        categoria: {
            nombre: "Fruta",
            id: "Fruta"
        },
        precio: 6000
    },
    {
        id: "Fruta-04",
        titulo: "Fresa",
        imagen: "../images/productos/fresa.png",//FOTO
        categoria: {
            nombre: "Fruta",
            id: "Fruta"
        },
        precio: 3700
    },
    {
        id: "Fruta-05",
        titulo: "Piña",
        imagen: "../images/productos/piña.png",//FOTO
        categoria: {
            nombre: "Fruta",
            id: "Fruta"
        },
        precio: 5000
    },
    {
        id: "Fruta-06",
        titulo: "Mora",
        imagen: "../images/productos/MORA.png",//FOTO
        categoria: {
            nombre: "Fruta",
            id: "Fruta"
        },
        precio: 5000
    },
    {
        id: "Fruta-07",
        titulo: "Papaya",
        imagen: "../images/productos/Papaya.png",//FOTO
        categoria: {
            nombre: "Fruta",
            id: "Fruta"
        },
        precio: 4500
    },
    {
        id: "Fruta-08",
        titulo: "Guayaba",
        imagen: "../images/productos/guayaba.png",//FOTO
        categoria: {
            nombre: "Fruta",
            id: "Fruta"
        },
        precio: 3500
    },
    //VERDURAS
    {
        id: "Verdura-01",
        titulo: "Auyama",
        imagen: "../images/productos/auyama.png",//FOTO
        categoria: {
            nombre: "Verdura",
            id: "Verdura"
        },
        precio: 4500
    },
    {
        id: "Verdura-02",
        titulo: "Acelga",
        imagen: "../images/productos/acelga.png",//FOTO
        categoria: {
            nombre: "Verdura",
            id: "Verdura"
        },
        precio: 1500
    },
    {
        id: "Verdura-03",
        titulo: "Habichuela",
        imagen: "../images/productos/habichuelas.png",//FOTO
        categoria: {
            nombre: "Verdura",
            id: "Verdura"
        },
        precio: 3000
    },
    {
        id: "Verdura-04",
        titulo: "Brocoli",
        imagen: "../images/productos/brocoli.png",//FOTO
        categoria: {
            nombre: "Verdura",
            id: "Verdura"
        },
        precio: 2500
    },
    {
        id: "Verdura-05",
        titulo: "Mazorca",
        imagen: "../images/productos/mazorca.png",//FOTO
        categoria: {
            nombre: "Verdura",
            id: "Verdura"
        },
        precio: 4500
    }
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
