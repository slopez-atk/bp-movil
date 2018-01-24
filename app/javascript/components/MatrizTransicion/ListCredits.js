import React from 'react';
import {BootstrapTable, TableHeaderColumn} from 'react-bootstrap-table';
import MenuItem from 'material-ui/MenuItem';
import RaisedButton from 'material-ui/RaisedButton';
import Paper from 'material-ui/Paper';

// Formsy
import { FormsySelect } from 'formsy-material-ui';
import Formsy from 'formsy-react';

class ListCredits extends React.Component{
  constructor(props){
    super(props);
    this.state = {
      calificacion1: "",
      calificacion2: "",
      canSubmit: false
    }
  }

  createCustomToolBar = props => {

    return (
      <div style={ { margin: '15px' } }>
        { props.components.btnGroup }
        <div className='col-xs-8 col-sm-4 col-md-4 col-lg-2'>
          { props.components.searchPanel }
        </div>
      </div>
    );
  };

  syncFields(event, value, index, fieldName){
    let jsonState = {};
    jsonState[fieldName] = value;
    this.setState(jsonState)
  }

  enableSubmitButton(){
    this.setState({
      canSubmit: true
    })
  }

  disableSubmitButton(){
    this.setState({
      canSubmit: false
    })
  }

  getForm(){
    return(
      <Paper zDepth={3} className="padding">
        <Formsy.Form onValid={()=> this.enableSubmitButton()}
                     onInvalid={ ()=> this.disableSubmitButton()}
                     onValidSubmit={this.props.onClick(this.state.calificacion1, this.state.calificacion2)}
        >
          <div>
            <h5 style={{color: "#FFC107"}}>Elige las calificaciones</h5>
            <FormsySelect
              style={{textAlign: 'left'}}
              floatingLabelText="Calificación 1"
              required
              // floatingLabelStyle={{color: muiTheme.palette.primary1Color}}
              name="calificacion1"
              onChange={(event, value, index) => this.syncFields(event, value, index, "calificacion1")}>
              <MenuItem value={'A1'} primaryText="A1" />
              <MenuItem value={'A2'} primaryText="A2" />
              <MenuItem value={'A3'} primaryText="A3" />
              <MenuItem value={'B1'} primaryText="B1" />
              <MenuItem value={'B2'} primaryText="B2" />
              <MenuItem value={'C1'} primaryText="C1" />
              <MenuItem value={'C2'} primaryText="C2" />
              <MenuItem value={'D'} primaryText="D" />
              <MenuItem value={'E'} primaryText="E" />
            </FormsySelect>
          </div>

          <div>
            <FormsySelect
              style={{textAlign: 'left'}}
              required
              floatingLabelText="Calificación 2"
              // floatingLabelStyle={{color: muiTheme.palette.primary1Color}}
              name="calificacion2"
              onChange={(event, value, index) => this.syncFields(event, value, index, "calificacion2")}>
              <MenuItem value={'A1'} primaryText="A1" />
              <MenuItem value={'A2'} primaryText="A2" />
              <MenuItem value={'A3'} primaryText="A3" />
              <MenuItem value={'B1'} primaryText="B1" />
              <MenuItem value={'B2'} primaryText="B2" />
              <MenuItem value={'C1'} primaryText="C1" />
              <MenuItem value={'C2'} primaryText="C2" />
              <MenuItem value={'D'} primaryText="D" />
              <MenuItem value={'E'} primaryText="E" />
            </FormsySelect>
          </div>

          <div>
            <RaisedButton
              secondary={true}
              label="Consultar"
              type="submit"
              disabled={ !this.state.canSubmit }
              labelColor="#ffffff"
            />
          </div>
        </Formsy.Form>
      </Paper>
    );
  }

  render(){
    const options = {
      onRowMouseOver: this.getFilteredResult,
      toolBar: this.createCustomToolBar
    };
    return(
      <div className="row center-xs middle-xs">
        <div className="col-xs-12">
          <BootstrapTable ref='table' data={ this.props.data } pagination exportCSV={ true } striped hover condensed options={ options }>
            <TableHeaderColumn dataField='socio' dataSort={ true } filter={ { type: 'TextFilter', delay: 1000 }} width={'120'}>Socio</TableHeaderColumn>
            <TableHeaderColumn dataField='nombre' dataSort={ true } filter={ { type: 'TextFilter', delay: 1000 }} width={'350'}>Nombre</TableHeaderColumn>
            <TableHeaderColumn dataField='cedula' dataSort={ true } filter={ { type: 'TextFilter', delay: 1000 }} width={'140'}>Cédula</TableHeaderColumn>
            <TableHeaderColumn dataField='edad' dataSort={ true } width={'110'}>Edad</TableHeaderColumn>
            <TableHeaderColumn dataField='genero' dataSort={ true }  width={'120'}>Genero</TableHeaderColumn>
            <TableHeaderColumn dataField='estado_civil' dataSort={ true } width={'160'}>Estado Civil</TableHeaderColumn>
            <TableHeaderColumn dataField='nivel_de_instruccion' dataSort={ true } width={'170'}>Nivel Instruccion</TableHeaderColumn>
            <TableHeaderColumn dataField='canton' dataSort={ true } width={'200'}>Cantón</TableHeaderColumn>
            <TableHeaderColumn dataField='provincia' dataSort={ true } width={'160'}>Provincia</TableHeaderColumn>
            <TableHeaderColumn dataField='credito' isKey={ true } dataSort={ true } filter={ { type: 'TextFilter', delay: 1000 }} width={'120'}>Credito</TableHeaderColumn>
            <TableHeaderColumn dataField='fecha_concesion' dataSort={ true } width={'280'}>Fecha Concesion</TableHeaderColumn>
            <TableHeaderColumn dataField='fecha_vencimiento' dataSort={ true } width={'280'}>Fecha Vencimiento</TableHeaderColumn>
            <TableHeaderColumn dataField='nom_grupo' dataSort={ true } width={'190'}>Nombre Grupo</TableHeaderColumn>
            <TableHeaderColumn dataField='garantia_vima' dataSort={ true } width={'190'}>Garantía Vima</TableHeaderColumn>
            <TableHeaderColumn dataField='diasmora_pd' dataSort={ true } width={'170'}>D. Mora</TableHeaderColumn>
            <TableHeaderColumn dataField='codigo_perioc' dataSort={ true } width={'170'}>Código Perioc</TableHeaderColumn>
            <TableHeaderColumn dataField='cuotas_credito' dataSort={ true } width={'170'}>Cuotas Crédito</TableHeaderColumn>
            <TableHeaderColumn dataField='cuotas_p' dataSort={ true } width={'170'}>Cuotas P.</TableHeaderColumn>
            <TableHeaderColumn dataField='cuota_vencida' dataSort={ true } width={'200'}>Cuota Vencida</TableHeaderColumn>
            <TableHeaderColumn dataField='val_credito' dataSort={ true } width={'200'}>Val Crédito</TableHeaderColumn>
            <TableHeaderColumn dataField='cap_activo' dataSort={ true } width={'200'}>Cap Activo</TableHeaderColumn>
            <TableHeaderColumn dataField='cap_ndevenga' dataSort={ true } width={'200'}>Cap No Devenga</TableHeaderColumn>
            <TableHeaderColumn dataField='cap_vencido' dataSort={ true } width={'200'}>Cap Vencido</TableHeaderColumn>
            <TableHeaderColumn dataField='cartera_riesgo' dataSort={ true } width={'150'}>Cartera Riesgo</TableHeaderColumn>
            <TableHeaderColumn dataField='cap_saldo' dataSort={ true } width={'200'}>Cap Saldo</TableHeaderColumn>
            <TableHeaderColumn dataField='valor_cancela' dataSort={ true } width={'120'}>Valor Cancela</TableHeaderColumn>
            <TableHeaderColumn dataField='tasa' dataSort={ true } width={'120'}>Tasa</TableHeaderColumn>
            <TableHeaderColumn dataField='oficina' dataSort={ true } width={'170'}>Oficina</TableHeaderColumn>
            <TableHeaderColumn dataField='cartera_heredada' dataSort={ true } width={'280'}>Cartera H.</TableHeaderColumn>
            <TableHeaderColumn dataField='asesor' dataSort={ true } width={'280'} filter={ { type: 'TextFilter', delay: 1000 }}>Asesor</TableHeaderColumn>
            <TableHeaderColumn dataField='sector' dataSort={ true } width={'90'} filter={ { type: 'TextFilter', delay: 1000 }}>Sector</TableHeaderColumn>
            <TableHeaderColumn dataField='parroquia' dataSort={ true } width={'200'}>Parroquia</TableHeaderColumn>
            <TableHeaderColumn dataField='ae_sector' dataSort={ true } width={'450'}>Actividad Económica Sector</TableHeaderColumn>
            <TableHeaderColumn dataField='ae_subsector' dataSort={ true } width={'450'}>Actividad Económica Subsector</TableHeaderColumn>

          </BootstrapTable>
        </div>
        <div className="col-xs-12 col-md-4 top-space bottom-space">
          { this.getForm() }
        </div>
      </div>
    );
  }
}

export default ListCredits;