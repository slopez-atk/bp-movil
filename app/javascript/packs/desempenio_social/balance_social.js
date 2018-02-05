import React from 'react';
import Paper from 'material-ui/Paper';
import WebpackerReact from 'webpacker-react';
import ReactHTMLTableToExcel from 'react-html-table-to-excel';
import NumberFormat from 'react-number-format';

//Material Ui
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import getMuiTheme from 'material-ui/styles/getMuiTheme';

const style = {
  tr: {
    textAlign: 'center',
    whiteSpace: 'normal',
    wordWrap: 'break-word',
  },
  markRow: {
    backgroundColor:'#3F51B5',
    color: '#fff'
  },
  sizeRow: {
    width: '250px'
  },
  headerRow: {
    backgroundColor:'#FFC107',
    color: "#000",
    textAlign: 'center',
    fontSize: "15px"
  },
  cuentasRow: {
    width: "250px",
    fontWeight: "bold"
  }
};

const muiTheme = getMuiTheme({
  drawer: {
    color: '#FDD835'
  },
  appBar: {
    color: '#2E3092'
  },
  palette: {
    primary1Color: "#3F51B5",
    accent1Color: "#FFC107",
  }
});
class BalanceSocial extends React.Component {

  constructor(props){
    super(props);
  }

  getBody(data){
    let estilos = {
      textAlign: "left"
    };
    return data.map(row => {
      if(row.cuenta === "Total valor económico directo creado"){
        return <tr style={estilos}>{this.getRow(row, true)}</tr>
      } else if(row.cuenta === "Total valor económico distribuido"){
        return <tr style={estilos}>{this.getRow(row, true)}</tr>
      }else{
        return <tr style={estilos}>{this.getRow(row, false)}</tr>
      }
    });
  }

  getLastRow(){
    let estilos = {
      backgroundColor:'#FFC107',
      color: '#0e0e0e',
      textAlign: "left"
    };
    let estilosNumeros = {
      backgroundColor:'#FFC107',
      color: '#0e0e0e',
      textAlign: "right"
    };
    return(
      <tr >
        <td style={estilos}>Total(Total Directo / Total Distribuido)</td>
        <td style={estilosNumeros}>{this.props.total[0]}%</td>
        <td style={estilos}> </td>
        <td style={estilosNumeros}>{this.props.total[0]}%</td>
        <td style={estilos}> </td>
        <td style={estilos}> </td>
        <td style={estilos}> </td>
      </tr>
    );
  }

  getRow(row, marked){
    let result = [];
    let estilos = {};
    let estilosNumeros = {
      textAlign: "right"
    };
    if(marked){
      estilos = {
        backgroundColor:'#3F51B5',
        color: '#fff'
      };
      estilosNumeros = {
        backgroundColor:'#3F51B5',
        color: '#fff',
        textAlign: "right"
      }
    }
    result.push(<td style={estilos}>{ row.cuenta }</td>);
    result.push(<td style={estilosNumeros}><NumberFormat value={ row.valor_1 } displayType={'text'} thousandSeparator={true} prefix={'$'}/></td>);
    result.push(<td style={estilosNumeros}>{ row.porcentaje_1 }%</td>);
    result.push(<td style={estilosNumeros}><NumberFormat value={ row.valor_2 } displayType={'text'} thousandSeparator={true} prefix={'$'}/></td>);
    result.push(<td style={estilosNumeros}>{ row.porcentaje_2 }%</td>);
    result.push(<td style={estilosNumeros}><NumberFormat value={ row.variacion } displayType={'text'} thousandSeparator={true} prefix={'$'}/></td>);
    result.push(<td style={estilosNumeros}>{ row.tasa_variacion }</td>);

    return result
  }

  render(){
    return(
      <MuiThemeProvider muiTheme={getMuiTheme(muiTheme)}>
        <div className="bottom-space">

          <h4 style={{color: muiTheme.palette.accent1Color}} className="top-space">Tabla del Balance Social</h4>
          <ReactHTMLTableToExcel
            id="test-table-xls-button"
            className="btn btn-inverse top-space bottom-space"
            table="table-to-xls"
            filename="balance_social"
            sheet="Resultados"
            buttonText="Descargar excel"/>
          <Paper zDepth={4}>
            <div className="table-responsive top-space padding">
              <table className="table table-striped table-hover table-bordered padding" id="table-to-xls">
                <thead>
                <tr>
                  <th style={style.headerRow}>Cuenta</th>
                  <th style={style.headerRow}>{ this.props.mes_1 }</th>
                  <th style={style.headerRow}>% { this.props.mes_1 }</th>
                  <th style={style.headerRow}>{ this.props.mes_2}</th>
                  <th style={style.headerRow}>% { this.props.mes_2 }</th>
                  <th style={style.headerRow}>Diferencia</th>
                  <th style={style.headerRow}>Tasa de variación</th>
                </tr>
                </thead>
                <tbody>
                  {this.getBody(this.props.valor_directo)}
                  {this.getBody(this.props.valor_distribuido)}
                  {this.getLastRow()}
                </tbody>
              </table>
            </div>
          </Paper>
        </div>
      </MuiThemeProvider>
    );
  }
}
WebpackerReact.setup({BalanceSocial});