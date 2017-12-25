import React from 'react';
import Paper from 'material-ui/Paper';
import {Table, TableBody, TableFooter, TableHeader, TableHeaderColumn, TableRow, TableRowColumn} from 'material-ui/Table';

class MatrizSaldos extends React.Component{
  constructor(props){
    super(props);
    this.state = {
      sumaDiagonal: 0,
      creditosMejoran: 0,
      creditosEmpeoran: 0
    }
  }

  // Metodo que crea en una matriz
  crearMatrices(){
    let data = this.props.data;
    let matrizCalificaciones = this.props.matriz;
    let matrizDatos = [];
    let c1 = '';
    let c2 = '';
    let sumFila = 0;
    let sumColumna = 0;
    let sumTotal = 0;

    for(let k=0; k<10; k++) {
      matrizDatos[k] = new Array(10);
    }


    for(let i=0; i<9; i++){
      for(let j=0; j<9; j++){
        c1 = matrizCalificaciones[i][j][0];
        c2 = matrizCalificaciones[i][j][1];
        if( data[c1] === undefined ){
          matrizDatos[i][j] = 0
        } else if( data[c1][c2] === undefined ) {
          matrizDatos[i][j] = 0
        } else {
          let n = data[c1][c2];
          n.toFixed(2);
          matrizDatos[i][j] = n;
        }
      }
    }

    // Sumar las columnas
    for(let l=0; l<9; l++) {
      for (let m=0; m<9; m++) {
        sumColumna += matrizDatos[m][l];
      }
      matrizDatos[9][l] = sumColumna.toFixed(2);
      sumColumna = 0;
    }

    // Sumar las filas
    for(let n=0; n<9; n++){
      for(let o=0; o<9; o++){
        sumFila += matrizDatos[n][o];
      }
      matrizDatos[n][9] = sumFila.toFixed(2);
      sumTotal += sumFila;
      sumFila = 0;
    }
    matrizDatos[9][9] = sumTotal.toFixed(2);


    return matrizDatos;
  }

  getSumatorias(matrizDatos){
    let sumaDiagonal = 0;
    let creditosMejoran = 0;
    let creditosEmpeoran = 0;

    // Sumar diagonal
    for(let i=0; i<9; i++){
      sumaDiagonal += matrizDatos[i][i];
    }
    sumaDiagonal = sumaDiagonal.toFixed(2);

    //Sumar los creditos superios
    for(let i=1; i<9; i++){
      for(let j=0; j<i; j++){
        creditosMejoran += matrizDatos[i][j]
      }
    }
    creditosMejoran = creditosMejoran.toFixed(2);

    // Sumar los creditos inferiores
    for(let i=0; i<8; i++){
      for(let j=i+1; j<9; j++){
        creditosEmpeoran += matrizDatos[i][j]
      }
    }
    creditosEmpeoran = creditosEmpeoran.toFixed(2);

    return [creditosEmpeoran, sumaDiagonal, creditosMejoran, matrizDatos[9][9]];
  }

  getTableRow(data, pos, bol){
    return data.map((row, index) => {
      let style = {
        textAlign: 'center',
        whiteSpace: 'normal',
        wordWrap: 'break-word'
      };

      if(bol || index === 9){
        style = {
          textAlign: 'center',
          backgroundColor: '#3F51B5',
          whiteSpace: 'normal',
          wordWrap: 'break-word',
          color: 'white'
        };
      }

      if(pos === index){
        style = {
          textAlign: 'center',
          backgroundColor: '#FFC107',
          whiteSpace: 'normal',
          wordWrap: 'break-word'
        };
      }
      return <TableRowColumn style={style} key={index}>{ row }</TableRowColumn>
    });
  }


  render(){
    let datos = this.crearMatrices();
    let sumatorias = this.getSumatorias(datos);
    return(
      <div>
        <Paper zDepth={3} className="top-space bottom-space">
          <div className="table-responsive">
            <Table fixedHeader={true} fixedFooter={true} selectable={false}>
              <TableHeader displaySelectAll={false} adjustForCheckbox={false}>
                <TableRow>
                  <TableHeaderColumn colSpan="11" tooltip="Monto de Provisión en cada calificación" style={{textAlign: 'center'}}>
                    Monto de Provisión en cada calificación
                  </TableHeaderColumn>
                </TableRow>
                <TableRow>
                  <TableHeaderColumn tooltip="Calificaciones">Calificacion</TableHeaderColumn>
                  <TableHeaderColumn tooltip="A1" style={{textAlign: 'center'}}>A1</TableHeaderColumn>
                  <TableHeaderColumn tooltip="A2" style={{textAlign: 'center'}}>A2</TableHeaderColumn>
                  <TableHeaderColumn tooltip="A3" style={{textAlign: 'center'}}>A3</TableHeaderColumn>
                  <TableHeaderColumn tooltip="B1" style={{textAlign: 'center'}}>B1</TableHeaderColumn>
                  <TableHeaderColumn tooltip="B2" style={{textAlign: 'center'}}>B2</TableHeaderColumn>
                  <TableHeaderColumn tooltip="C1" style={{textAlign: 'center'}}>C1</TableHeaderColumn>
                  <TableHeaderColumn tooltip="C2" style={{textAlign: 'center'}}>C2</TableHeaderColumn>
                  <TableHeaderColumn tooltip="D" style={{textAlign: 'center'}}>D</TableHeaderColumn>
                  <TableHeaderColumn tooltip="E" style={{textAlign: 'center'}}>E</TableHeaderColumn>
                  <TableHeaderColumn tooltip="Total General" style={{textAlign: 'center'}}>Total</TableHeaderColumn>
                </TableRow>
              </TableHeader>
              <TableBody displayRowCheckbox={false} showRowHover={true} stripedRows={false} >
                <TableRow>
                  <TableRowColumn style={{textAlign: 'center'}}>A1</TableRowColumn>
                  { this.getTableRow(datos[0], 0, false)}
                </TableRow>
                <TableRow>
                  <TableRowColumn style={{textAlign: 'center'}}>A2</TableRowColumn>
                  { this.getTableRow(datos[1], 1, false)}
                </TableRow>
                <TableRow>
                  <TableRowColumn style={{textAlign: 'center'}}>A3</TableRowColumn>
                  { this.getTableRow(datos[2], 2, false)}
                </TableRow>
                <TableRow>
                  <TableRowColumn style={{textAlign: 'center'}}>B1</TableRowColumn>
                  { this.getTableRow(datos[3], 3, false)}
                </TableRow>
                <TableRow>
                  <TableRowColumn style={{textAlign: 'center'}}>B2</TableRowColumn>
                  { this.getTableRow(datos[4], 4, false)}
                </TableRow>
                <TableRow>
                  <TableRowColumn style={{textAlign: 'center'}}>C1</TableRowColumn>
                  { this.getTableRow(datos[5], 5, false)}
                </TableRow>
                <TableRow>
                  <TableRowColumn style={{textAlign: 'center'}}>C2</TableRowColumn>
                  { this.getTableRow(datos[6], 6, false)}
                </TableRow>
                <TableRow>
                  <TableRowColumn style={{textAlign: 'center'}}>D</TableRowColumn>
                  { this.getTableRow(datos[7], 7, false)}
                </TableRow>
                <TableRow>
                  <TableRowColumn style={{textAlign: 'center'}}>E</TableRowColumn>
                  { this.getTableRow(datos[8], 8, false)}
                </TableRow>
                <TableRow>
                  <TableRowColumn style={{textAlign: 'center'}}>Total</TableRowColumn>
                  { this.getTableRow(datos[9], 10, true)}
                </TableRow>
              </TableBody>
            </Table>
          </div>
        </Paper>


        <div className="row center-xs middle-xs">
          <div className="col-xs-12 col-md-4">
            <Paper zDepth={4} className="top-space bottom-space padding">
              <Table fixedHeader={true}>
                <TableHeader displaySelectAll={false} adjustForCheckbox={false}>
                  <TableRow>
                    <TableHeaderColumn colSpan="3" tooltip="Resumen" style={{textAlign: 'center'}}>
                      Resumen
                    </TableHeaderColumn>
                  </TableRow>
                  <TableRow>
                    <TableHeaderColumn tooltip="Descripción">Descripción</TableHeaderColumn>
                    <TableHeaderColumn tooltip="Cantidad">Cantidad</TableHeaderColumn>
                    <TableHeaderColumn tooltip="Procentaje" style={{textAlign: 'center'}}>Porcentaje</TableHeaderColumn>
                  </TableRow>
                </TableHeader>
                <TableBody displayRowCheckbox={false} showRowHover={true} stripedRows={false}>
                  <TableRow>
                    <TableRowColumn style={{textAlign: 'center', backgroundColor: '#EF5350', color: "white"}}>Empeoran</TableRowColumn>
                    <TableRowColumn style={{textAlign: 'center'}}>{sumatorias[0]}</TableRowColumn>
                    <TableRowColumn style={{textAlign: 'center'}}>{ ((sumatorias[0]*100)/sumatorias[3]).toFixed(2) } %</TableRowColumn>
                  </TableRow>

                  <TableRow>
                    <TableRowColumn style={{textAlign: 'center', backgroundColor: '#FFEE58'}}>Mantienen</TableRowColumn>
                    <TableRowColumn style={{textAlign: 'center'}}>{sumatorias[1]}</TableRowColumn>
                    <TableRowColumn style={{textAlign: 'center'}}>{ ((sumatorias[1]*100)/sumatorias[3]).toFixed(2) } %</TableRowColumn>
                  </TableRow>

                  <TableRow>
                    <TableRowColumn style={{textAlign: 'center', backgroundColor: '#26C6DA'}}>Mejoran</TableRowColumn>
                    <TableRowColumn style={{textAlign: 'center'}}>{sumatorias[2]}</TableRowColumn>
                    <TableRowColumn style={{textAlign: 'center'}}>{ ((sumatorias[2]*100)/sumatorias[3]).toFixed(2) } %</TableRowColumn>
                  </TableRow>
                </TableBody>
              </Table>
            </Paper>
          </div>
        </div>
      </div>
    );
  }
}

export default MatrizSaldos;