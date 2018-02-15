import React from 'react';
import WebpackerReact from 'webpacker-react';
import CreditosPorVencerForm from '../components/CreditsForms/CreditosPorVencerForm';
import CreditosVencidosForm from '../components/CreditsForms/CreditosVencidosForm';
import CreditosConcedidosForm from '../components/CreditsForms/CreditosConcedidosForm';
import MatrizTransicionForm from '../components/CreditsForms/MatrizTransicionForm';
import IndicadoresVigentesForm from '../components/CreditsForms/IndicadoresVigentesForm';
import IndicadoresCreditosColocadosForm from '../components/CreditsForms/IndicadoresCreditosColocadosForm';

import Dialog from 'material-ui/Dialog';
import FlatButton from 'material-ui/FlatButton';


// Material ui
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import getMuiTheme from 'material-ui/styles/getMuiTheme';
import AppBar from 'material-ui/AppBar';
import Drawer from 'material-ui/Drawer';
import MenuItem from 'material-ui/MenuItem';
import Divider from 'material-ui/Divider';
import FloatingActionButton from 'material-ui/FloatingActionButton';

//Iconos
import ActionFeedback from 'material-ui/svg-icons/action/feedback';
import ActionDns from 'material-ui/svg-icons/action/dns';
import ActionViewQuilt from 'material-ui/svg-icons/action/view-quilt';
import ActionHome from 'material-ui/svg-icons/action/home';
import ViewDay from 'material-ui/svg-icons/action/view-day';
import ViewWeek from 'material-ui/svg-icons/action/view-week';
import DeveloperBoard from 'material-ui/svg-icons/hardware/developer-board';
import Equalizer from 'material-ui/svg-icons/av/equalizer';
import Event from 'material-ui/svg-icons/action/event';
import MarkunreadMailbox from 'material-ui/svg-icons/action/markunread-mailbox';


//Colores
import {
  yellow500, yellow700,
  deepOrangeA200,
  grey100, grey300, grey400, grey500,
  white, darkBlack, fullBlack,
} from 'material-ui/styles/colors';
import CosechasForm from "../components/CreditsForms/CosechasForm";


const customContentStyle = {
  width: '100%',
  maxWidth: '700px',
};

const muiTheme = getMuiTheme({
  drawer: {
    color: '#FDD835'
  },
  appBar: {
    color: '#2E3092'
  }
});

const styles = {
  logo: {
    cursor: 'pointer',
    fontSize: 23,
    backgroundColor: "#2E3092",
    paddingTop: 15,
    color: 'white',
    paddingLeft: 40,
    height: 64,
  },
  floatingButton: {
    margin: 0,
    top: 'auto',
    right: 20,
    bottom: 20,
    left: 'auto',
    position: 'fixed',
    zIndex: 10
  },
  div: {
    display: "flex",
    flexDirection: "row",
    flexWrap: "wrap",
    justifyContent: "center",
    alignItems: "center",
  }
};

class CreditosNavigation extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      open: false,
      openModalCreditosVencer: false,
      openModalCreditosVencidos: false,
      openModalMatrizRiesgos: false,
      openModalCreditosConcedidos: false,
      openModalCosechas: false,
      openModalIndicadoresColocados: false,
      openModalIndicadoresVigentes: false
    };
  }



  handleToggle = () => {
    this.setState({open: !this.state.open});
  };
  handleClose = () => {
    this.setState({open: false});
  };

  handleModal1 = () => {
    this.setState({openModalCreditosVencer: !this.state.openModalCreditosVencer});
  };
  handleModal2 = () => {
    this.setState({openModalCreditosVencidos: !this.state.openModalCreditosVencidos});
  };
  handleModal3 = () => {
    this.setState({openModalMatrizRiesgos: !this.state.openModalMatrizRiesgos});
  };
  handleModal4 = () => {
    this.setState({openModalCreditosConcedidos: !this.state.openModalCreditosConcedidos});
  };
  handleModal5 = () => {
    this.setState({openModalCosechas: !this.state.openModalCosechas});
  };
  handleModal6 = () => {
    this.setState({openModalIndicadoresVigentes: !this.state.openModalIndicadoresVigentes});
  };
  handleModal7 = () => {
    this.setState({openModalIndicadoresColocados: !this.state.openModalIndicadoresColocados});
  };

  handleLocation = (action) => {
    switch (action) {
      case 'home':
        window.location = '/credits';
        break;

      case 'dashboard':
        window.location = '/';
        break;
    }
  };

  getMenuItems(){
    let permissions = this.props.permissions;
    if(permissions == 5 || permissions == 3){
      return(
        <div>
          <Divider/>
          <MenuItem
            primaryText="Cartera Por Vencer"
            leftIcon={ <Event color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal1 }
          />
          <Divider/>
          <MenuItem
            primaryText="Cartera Vencida"
            leftIcon={ <ActionFeedback color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal2 }
          />
          <Divider/>
          <MenuItem
            primaryText="Eficiencia de Cartera"
            leftIcon={ <MarkunreadMailbox color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal4 }
          />
          <Divider/>
          <MenuItem
            primaryText="Matrices de Riesgo"
            leftIcon={ <ViewWeek color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal3 }
          />
          <Divider/>
          <MenuItem
            primaryText="Cosechas"
            leftIcon={ <ViewDay color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal5 }
          />
          <Divider/>
          <MenuItem
            primaryText="Indicadores C. Vigentes"
            leftIcon={ <DeveloperBoard color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal6 }
          />
          <Divider/>
          <MenuItem
            primaryText="Indicadores C. Colocados"
            leftIcon={ <Equalizer color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal7 }
          />
          <Divider/>
        </div>
      );
    } else if(permissions === 7 || permissions === 6){
      return(
        <div>
          <Divider/>
          <MenuItem
            primaryText="Cartera Por Vencer"
            leftIcon={ <Event color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal1 }
          />
          <Divider/>
          <MenuItem
            primaryText="Cartera Vencida"
            leftIcon={ <ActionFeedback color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal2 }
          />
          <Divider/>
          <MenuItem
            primaryText="Eficiencia de Cartera"
            leftIcon={ <MarkunreadMailbox color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal4 }
          />
          <Divider/>
          <MenuItem
            primaryText="Matrices de Riesgo"
            leftIcon={ <ViewWeek color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal3 }
          />
          <Divider/>
          <MenuItem
            primaryText="Cosechas"
            leftIcon={ <ViewDay color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal5 }
          />
          <Divider/>
          <MenuItem
            primaryText="Indicadores C. Vigentes"
            leftIcon={ <DeveloperBoard color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal6 }
          />
          <Divider/>
          <MenuItem
            primaryText="Indicadores C. Colocados"
            leftIcon={ <Equalizer color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal7 }
          />
          <Divider/>
        </div>
      );
    } else if(permissions === 8){
      return(
        <div>
          <Divider/>
          <MenuItem
            primaryText="Cartera Por Vencer"
            leftIcon={ <Event color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal1 }
          />
          <Divider/>
          <MenuItem
            primaryText="Cartera Vencida"
            leftIcon={ <ActionFeedback color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal2 }
          />
          <Divider/>
          <MenuItem
            primaryText="Eficiencia de Cartera"
            leftIcon={ <MarkunreadMailbox color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal4 }
          />
          <Divider/>
          <MenuItem
            primaryText="Matrices de Riesgo"
            leftIcon={ <ViewWeek color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal3 }
          />
          <Divider/>
          <MenuItem
            primaryText="Cosechas"
            leftIcon={ <ViewDay color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal5 }
          />
          <Divider/>
          <MenuItem
            primaryText="Indicadores C. Vigentes"
            leftIcon={ <DeveloperBoard color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal6 }
          />
          <Divider/>
          <MenuItem
            primaryText="Indicadores C. Colocados"
            leftIcon={ <Equalizer color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal7 }
          />
          <Divider/>
        </div>
      );
    }
  }


  render(){
    const actions1 = [
      <FlatButton
        label="Cancelar"
        primary={true}
        onClick={this.handleModal1}
      />,
    ];
    const actions2 = [
      <FlatButton
        label="Cancelar"
        primary={true}
        onClick={this.handleModal2}
      />,
    ];
    const actions3 = [
      <FlatButton
        label="Cancelar"
        primary={true}
        onClick={this.handleModal3}
      />,
    ];
    const actions4 = [
      <FlatButton
        label="Cancelar"
        primary={true}
        onClick={this.handleModal4}
      />,
    ];
    const actions5 = [
      <FlatButton
        label="Cancelar"
        primary={true}
        onClick={this.handleModal5}
      />,
    ];
    const actions6 = [
      <FlatButton
        label="Cancelar"
        primary={true}
        onClick={this.handleModal6}
      />,
    ];
    const actions7 = [
      <FlatButton
        label="Cancelar"
        primary={true}
        onClick={this.handleModal7}
      />,
    ];
    return(
      <MuiThemeProvider muiTheme={getMuiTheme(muiTheme)}>
        <div>
          <AppBar
            title="CACMU"
            iconClassNameRight="muidocs-icon-navigation-expand-more"
            onLeftIconButtonTouchTap={ this.handleToggle }
          />
          <Drawer open={ this.state.open } docked={false} onRequestChange={(open) => this.setState({open})}>
            <div style={styles.logo}>
              { this.props.names }
            </div>
            <MenuItem
              primaryText="Dashboard"
              leftIcon={ <ActionViewQuilt color='#444444'/>}
              style={{color: '#444444'}}
              onClick={()=> this.handleLocation('dashboard') }
            />
            <MenuItem
              primaryText="Inicio"
              leftIcon={ <ActionHome color='#444444'/>}
              style={{color: '#444444'}}
              onClick={()=> this.handleLocation('home') }
            />
            { this.getMenuItems() }

          </Drawer>

          <div>
            <FloatingActionButton style={styles.floatingButton}  disabled={false} onClick={ this.handleToggle } backgroundColor="#2E3092" >
              <ActionDns color="FDD835"/>
            </FloatingActionButton>
          </div>

          <div>
            <Dialog
              modal={true}
              contentStyle={customContentStyle}
              open={ this.state.openModalCreditosVencer }
              actions={actions1}
            >
              <div className="row center-xs middle-xs">
                <h4 style={{color: "#2E3092"}}>Cartera Por Vencer</h4>
                <div className="col-xs-10" style={styles.div}>
                  <CreditosPorVencerForm
                    authenticity_token={ this.props.authenticity_token }
                    url = '/credits/creditos_por_vencer'
                    title = 'Consultar creditos por vencer'/>
                </div>
              </div>
            </Dialog>
          </div>

          <div>
            <Dialog
              modal={true}
              contentStyle={customContentStyle}
              open={ this.state.openModalCreditosVencidos }
              actions={actions2}
              autoScrollBodyContent={true}
            >
              <div className="row center-xs middle-xs">
                <h4 style={{color: "#2E3092"}}>Cartera Vencida</h4>
                <div className="col-xs-10" style={styles.div}>
                  <CreditosVencidosForm
                    url='/credits/creditos_vencidos'
                    title='Consultar creditos vencidos'
                    authenticity_token={ this.props.authenticity_token }/>
                </div>
              </div>
            </Dialog>
          </div>

          <div>
            <Dialog
              modal={true}
              contentStyle={customContentStyle}
              open={ this.state.openModalMatrizRiesgos }
              actions={actions3}
              autoScrollBodyContent={true}>
              <div className="row center-xs middle-xs">
                <h4 style={{color: "#2E3092"}}>Matrices de Riesgo</h4>
                <div className="col-xs-10" style={styles.div}>
                  <MatrizTransicionForm
                    url='/credits/matrices'
                    authenticity_token={ this.props.authenticity_token }
                    title= "Matriz de transicion"/>
                </div>
              </div>
            </Dialog>
          </div>

          <div>
            <Dialog
              modal={true}
              contentStyle={customContentStyle}
              open={ this.state.openModalCreditosConcedidos }
              actions={actions4}
              autoScrollBodyContent={true}>
              <div className="row center-xs middle-xs">
                <h4 style={{color: "#2E3092"}}>Eficiencia de la Cartera</h4>
                <div className="col-xs-10" style={styles.div}>
                  <CreditosConcedidosForm
                    url='/credits/creditos_concedidos'
                    title='Consultar eficiencia de cartera'
                    authenticity_token={ this.props.authenticity_token }/>
                </div>
              </div>
            </Dialog>
          </div>

          <div>
            <Dialog
              modal={true}
              contentStyle={customContentStyle}
              open={ this.state.openModalCosechas }
              actions={actions5}
              autoScrollBodyContent={true}>
              <div className="row center-xs middle-xs">
                <h4 style={{color: "#2E3092"}}>Cosechas</h4>
                <div className="col-xs-10" style={styles.div}>
                  <CosechasForm
                    url='/credits/cosechas'
                    title='Reporte de Cosechas'
                    authenticity_token={ this.props.authenticity_token }/>
                </div>
              </div>
            </Dialog>
          </div>

          <div>
            <Dialog
              modal={true}
              contentStyle={customContentStyle}
              open={ this.state.openModalIndicadoresVigentes }
              actions={actions6}
              autoScrollBodyContent={true}>
              <div className="row center-xs middle-xs">
                <h4 style={{color: "#2E3092"}}>Indicadores de Creditos Vigentes</h4>
                <div className="col-xs-10" style={styles.div}>
                  <IndicadoresVigentesForm
                    url='/credits/indicadores_creditos_vigentes'
                    title='Indicadores creditos vigentes'
                    authenticity_token={ this.props.authenticity_token }/>
                </div>
              </div>
            </Dialog>
          </div>

          <div>
            <Dialog
              modal={true}
              contentStyle={customContentStyle}
              open={ this.state.openModalIndicadoresColocados }
              actions={actions7}
              autoScrollBodyContent={true}>
              <div className="row center-xs middle-xs">
                <h4 style={{color: "#2E3092"}}>Indicadores de Creditos Colocados</h4>
                <div className="col-xs-10" style={styles.div}>
                  <IndicadoresCreditosColocadosForm
                    url='/credits/indicadores_creditos_colocados'
                    title='Indicadores creditos colocados'
                    authenticity_token={ this.props.authenticity_token }/>
                </div>
              </div>
            </Dialog>
          </div>




        </div>
      </MuiThemeProvider>
    );
  }

}
WebpackerReact.setup({CreditosNavigation});