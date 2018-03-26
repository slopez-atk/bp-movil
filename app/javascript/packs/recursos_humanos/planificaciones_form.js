import React from 'react';
import ReactDOM from 'react-dom';
import moment from 'moment';


// Material ui

import RaisedButton from 'material-ui/RaisedButton';
import Dialog from 'material-ui/Dialog';
import FloatingActionButton from 'material-ui/FloatingActionButton';
import FlatButton from 'material-ui/FlatButton';
import getMuiTheme from 'material-ui/styles/getMuiTheme';
import reqwest from 'reqwest';

// Formsy
import { FormsyDate } from 'formsy-material-ui';
import Formsy from 'formsy-react';
import FormsyText from 'formsy-material-ui/lib/FormsyText';

// Iconos
import ActionToday from 'material-ui/svg-icons/action/today';

const muiTheme = getMuiTheme({
  palette: {
    primary1Color: "#3F51B5",
    accent1Color: "#FFC107",
    textColor: '#34495e'
  }
});

const styles = {
  floatingButton: {
    margin: 0,
    top: 'auto',
    left: 20,
    bottom: 20,
    right: 'auto',
    position: 'fixed',
    zIndex: 10
  }
};

const customContentStyle = {
  width: '100%',
  maxWidth: '700px',
};




class PlanificacionesForm extends React.Component{

  constructor(props){
    super(props);
    this.state = {
      fechaInicio: '',
      fechaFin: '',
      canSubmit: false,
      trabajador: 0,
      openModal: false,
    }
  }

  handleModal = () => {
    this.setState({openModal: !this.state.openModal});
  };

  submit(){
    reqwest({
      url: '/worker_planifications.json?id='+this.props.worker_id,
      method: 'POST',
      data: {
        worker_planification: {
          start_date: this.state.fechaInicio,
          end_date: this.state.fechaFin,
        }
      },
      headers: {
        'X-CSRF-Token': this.props.authenticity_token
      }
    }).then(planificacions => {
      this.props.onClick(planificacions)
    })
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

  syncFechas(event, date, fieldName){
    let value = moment(date).format('DD-MM-YYYY');
    let jsonState = {};
    jsonState[fieldName] = value;
    this.setState(jsonState)
  }

  render(){
    const actions = [
      <FlatButton
        label="Cerrar"
        primary={true}
        onClick={this.handleModal}
      />,
    ];
    return(
      <div>
        <Dialog
          modal={true}
          contentStyle={customContentStyle}
          open={ this.state.openModal }
          actions={actions}
          autoScrollBodyContent={true}
        >
          <div className="row center-xs">
            <div className="col-xs-10">
              <h5 style={{color: muiTheme.palette.accent1Color}}>Ingresar planificación</h5>
              <Formsy.Form
                onValid={()=> this.enableSubmitButton()}
                onValidSubmit={()=> this.submit()}
                onInvalid={ ()=> this.disableSubmitButton()}
              >

                <div>
                  <FormsyDate
                    floatingLabelStyle={{color: muiTheme.palette.primary1Color}}
                    onChange={ (ev, date)=> this.syncFechas(ev, date, 'fechaInicio') }
                    name="worker_planification[start_date]"
                    required
                    floatingLabelText="Fecha Inicio"/>
                </div>

                <div>
                  <FormsyDate
                    floatingLabelStyle={{color: muiTheme.palette.primary1Color}}
                    onChange={ (ev, date)=> this.syncFechas(ev, date, 'fechaFin') }
                    name="worker_planification[end_date]"
                    required
                    floatingLabelText="Fecha Finalización"/>
                </div>


                <div>
                  <RaisedButton
                    primary={true}
                    type="submit"
                    label="Ingresar"
                    disabled={ !this.state.canSubmit }
                    labelColor="#ffffff"
                    ref="submitButton"
                  />
                </div>
              </Formsy.Form>
            </div>
          </div>
        </Dialog>
        <div>
          <FloatingActionButton style={styles.floatingButton}  disabled={false} onClick={ this.handleModal } backgroundColor="#2E3092" >
            <ActionToday color="FDD835"/>
          </FloatingActionButton>
        </div>
      </div>
    );
  }
}

export default PlanificacionesForm;