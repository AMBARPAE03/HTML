//PROGRAMACION DE TRANSCION DE AMBOS FORMULARIOS
const signUpButton = document.getElementById("signUp");
const signInButton = document.getElementById("signIn");
const container = document.getElementById("container");
//evento de espera de click
signUpButton.addEventListener('click', () => {
    container.classList.add("right-panel-active");
});

signInButton.addEventListener('click',() => {
    container.classList.remove("right-panel-active");
});
