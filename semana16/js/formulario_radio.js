function ingresar(){
    let nombre,edad,estado,institucion;
    nombre=document.getElementById("nom").value;
    edad=document.getElementById("ed").value;
    institucion=document.getElementById("ins").value;
    //
    if(document.getElementById('radio1').checked){
        estado="sin nivel de estudios";
    }else if(document.getElementById('radio2').checked){
        estado="PRIMARIA";
    }else if(document.getElementById('radio3').checked){
        estado="SECUNDARIA";
    }else if(document.getElementById('radio4').checked){
        estado="TECNICO";
    }else if(document.getElementById('radio5').checked){
        estado="UNIVERSITARIO";
    }else if(document.getElementById('radio6').checked){
        estado="OTRO TIPO DE ESTUDIOS";
    }
    alert('El estudiante:..'+nombre+' cuya edad es:...'+edad+'años,'+'\n'+'nivel de estuidos:..'+estado+'\n'+'graduado en la institucion:'+institucion);
}