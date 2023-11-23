function apostar(){
    //calcular numero apostado aleatorio
    var a=Math.round(Math.random()*10);
    //transferencia de variable de JS al formulario
    document.getElementById("resultado").value=a;
    //transferencia de formulario al JS
    var b=document.getElementById("apostado").value;
    //resultados
    if (a==b){
        document.getElementById("salida").value="gano";
    } else{
        document.getElementById("salida").value="perdio";
    }
}
function cancel(){
    document.getElementById("apostado").value=" ";
    document.getElementById("resultado").value=" ";
    document.getElementById("salida").value=" ";
}


