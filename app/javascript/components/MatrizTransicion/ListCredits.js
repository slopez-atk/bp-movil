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
            <TableHeaderColumn dataField='credito' isKey={ true } dataSort={ true }>Credito</TableHeaderColumn>
            <TableHeaderColumn dataField='socio' dataSort={ true }>Socio</TableHeaderColumn>
            <TableHeaderColumn dataField='nombre' dataSort={ true } filter={ { type: 'TextFilter', delay: 1000 }}>NOMBRES</TableHeaderColumn>
            <TableHeaderColumn dataField='cap_saldo' dataSort={ true }>Saldo</TableHeaderColumn>
            <TableHeaderColumn dataField='diasmora_pd' dataSort={ true }>D. Mora</TableHeaderColumn>
            <TableHeaderColumn dataField='oficina' dataSort={ true }>Oficina</TableHeaderColumn>
            <TableHeaderColumn dataField='of_cred' dataSort={ true }>Oficial C.</TableHeaderColumn>
            <TableHeaderColumn dataField='cartera_heredada' dataSort={ true }>Cartera H.</TableHeaderColumn>
            <TableHeaderColumn dataField='liquidador' dataSort={ true }>Liquidador</TableHeaderColumn>
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