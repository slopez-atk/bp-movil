import React from 'react';
import WebpackerReact from 'webpacker-react';
import ReactHTMLTableToExcel from 'react-html-table-to-excel';
import NumberFormat from 'react-number-format';
import Graficas from '../../components/Agencias/IndicadoresFinancieros/Graficas';

//Material Ui
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import getMuiTheme from 'material-ui/styles/getMuiTheme';
import Paper from 'material-ui/Paper';
import Dialog from 'material-ui/Dialog';
import FlatButton from 'material-ui/FlatButton';
import RaisedButton from 'material-ui/RaisedButton';

const styles = {
  tr: {
    textAlign: 'center',
    whiteSpace: 'normal',
    wordWrap: 'break-word',
  },
  markRow: {
    backgroundColor:'#3F51B5',
    color: '#fff'
  },
  td: {
    backgroundColor: '#FFF59B',
    color: 'fff',
    fontWeight: 'bold',
    fontSize: '15px',
    height: '50px'
  },
  headerRow: {
    backgroundColor:'#3F51B5',
    color: '#fff',
    textAlign: 'center',
    fontSize: "17px",
    minWidth: '230px',
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

const customContentStyle = {
  width: '100%',
  maxWidth: 'none',
};

class IndicadoresSeps extends React.Component {


  constructor(props){
    super(props)
    this.state = {
      dataGraphic: [],
      titulo: '',
      open: false
    };
    this.setDataGraphic = this.setDataGraphic.bind(this);
  }

  handleOpen = () => {
    this.setState({open: true});
  };

  handleClose = () => {
    this.setState({open: false});
  };

  setDataGraphic(data, titulo){
    this.setState({
      dataGraphic: data,
      titulo: titulo
    });
    this.handleOpen();
  }

  getBody(indicador, data){
    let fila = data.map(row => {
      let valor = 0.0;
      if(indicador === 'Apalancamiento'){
        valor = row
      } else {
        valor = row * 100
      }
      return(
        <td style={styles.td}>
          <NumberFormat value={ parseFloat(valor).toFixed(2) } displayType={'text'} thousandSeparator={true} suffix={'%'}/>
        </td>
      )
    });
    let titulo = "Gráfica - " + indicador
    fila.unshift(<td style={styles.markRow}>{indicador}</td>);
    fila.push(<RaisedButton label="Ver" primary onClick={()=>  this.setDataGraphic(data, titulo)}/>);
    return fila;
  }


  render(){
    const actions = [
      <FlatButton
        label="Cerrar Ventana"
        primary={true}
        onClick={this.handleClose}
      />,
    ];
    return(
      <MuiThemeProvider muiTheme={getMuiTheme(muiTheme)}>
        <div>
          <h4 style={{color: muiTheme.palette.accent1Color}} className="top-space botton-space">INDICADORES SEPS</h4>
          <ReactHTMLTableToExcel
            id="test-table-xls-button"
            className="btn btn-inverse top-space bottom-space"
            table="table-to-xls"
            filename="indicadores_seps"
            sheet="indicadores"
            buttonText="Descargar excel"/>

          <Paper zDepth={4}>
            <div className="table-responsive top-space padding">
              <table className="table table-striped table-hover table-bordered padding" id="table-to-xls">

                <thead>
                  <tr style={styles.tr}>
                    <th style={styles.headerRow}>Indicadores</th>
                    <th style={styles.headerRow}>dic-{ this.props.last_year }</th>
                    <th style={styles.headerRow}>ene-{ this.props.year }</th>
                    <th style={styles.headerRow}>feb-{ this.props.year }</th>
                    <th style={styles.headerRow}>mar-{ this.props.year }</th>
                    <th style={styles.headerRow}>abr-{ this.props.year }</th>
                    <th style={styles.headerRow}>may-{ this.props.year }</th>
                    <th style={styles.headerRow}>jun-{ this.props.year }</th>
                    <th style={styles.headerRow}>jul-{ this.props.year }</th>
                    <th style={styles.headerRow}>ago-{ this.props.year }</th>
                    <th style={styles.headerRow}>sep-{ this.props.year }</th>
                    <th style={styles.headerRow}>oct-{ this.props.year }</th>
                    <th style={styles.headerRow}>nov-{ this.props.year }</th>
                    <th style={styles.headerRow}>dic-{ this.props.year }</th>
                    <th style={styles.headerRow}>Gráfica</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>{this.getBody("Solvencia normativa", this.props.solvencia_normativa)}</tr>
                  <tr>{this.getBody("Apalancamiento", this.props.apalancamiento)}</tr>
                  <tr>{this.getBody("Liquidez", this.props.liquidez)}</tr>
                  <tr>{this.getBody("Morosidad Ampliada", this.props.morosidad_ampliada)}</tr>
                  <tr>{this.getBody("Cobertura de Provisiones", this.props.covertura_provision)}</tr>
                  <tr>{this.getBody("Relación de Productividad", this.props.relacion_productividad)}</tr>
                  <tr>{this.getBody("ROA", this.props.roa)}</tr>
                  <tr>{this.getBody("Eficiencia Institucional en Colocación", this.props.eficiencia_institucional)}</tr>
                  <tr>{this.getBody("Grado de Absorción de Margen Financiero Neto", this.props.grado_absorcion_mf)}</tr>
                  <tr> {this.getBody("Tasa Activa General", this.props.tasa_activa)}</tr>
                  <tr>{this.getBody("Tasa Pasiva General", this.props.tasa_pasiva_general)}</tr>
                  <tr>{this.getBody("Roe", this.props.solvencia_normativa)}</tr>
                </tbody>
              </table>
            </div>
          </Paper>

          <Dialog
            title={this.state.titulo}
            actions={actions}
            modal={true}
            contentStyle={customContentStyle}
            open={this.state.open}
            autoScrollBodyContent={true}>

            <Graficas data={this.state.dataGraphic} titulo={this.state.titulo}/>

          </Dialog>
        </div>
      </MuiThemeProvider>
    );
  }
}

WebpackerReact.setup({IndicadoresSeps});