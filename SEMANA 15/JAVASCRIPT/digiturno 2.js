var turno=['F01','P01','Q01','M01','F02','P02'];
var modulo=['01','02','03','04','05','06'];

function tick(){
    let con=1;
    let ce=0;
    while (con<=6){
        document.getElementById("t"+con).vale=turno[ce];
        document.getElementById("m"+con).vale=modulo[ce];
        ++ce;
        ++con;
    }
}