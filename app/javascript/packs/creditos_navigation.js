import React from 'react';
import WebpackerReact from 'webpacker-react';
import CreditosPorVencerForm from '../components/CreditsForms/CreditosPorVencerForm';
import CreditosVencidosForm from '../components/CreditsForms/CreditosVencidosForm';
import CreditosConcedidosForm from '../components/CreditsForms/CreditosConcedidosForm';
import MatrizTransicionForm from '../components/CreditsForms/MatrizTransicionForm';

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
import ActionAssessment from 'material-ui/svg-icons/action/assessment';
import ActionFeedback from 'material-ui/svg-icons/action/feedback';
import ActionDns from 'material-ui/svg-icons/action/dns';
import ActionViewQuilt from 'material-ui/svg-icons/action/view-quilt';
import ActionHome from 'material-ui/svg-icons/action/home';


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
      openModalCosechas: false
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

  handleLocation = (action) => {
    switch (action) {
      case 'home':
        window.location = '/credits';

      case 'dashboard':
        window.location = '/';
    }
  };


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
            <MenuItem
              primaryText="Cartera Por Vencer"
              leftIcon={ <ActionAssessment color='#444444'/>}
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
              primaryText="Matrices de Riesgo"
              leftIcon={ <ActionAssessment color='#444444'/>}
              style={{color: '#444444'}}
              onClick={ this.handleModal3 }
            />
            <Divider/>
            <MenuItem
              primaryText="Cartera Concedida"
              leftIcon={ <ActionAssessment color='#444444'/>}
              style={{color: '#444444'}}
              onClick={ this.handleModal4 }
            />
            <MenuItem
              primaryText="Cosechas"
              leftIcon={ <ActionAssessment color='#444444'/>}
              style={{color: '#444444'}}
              onClick={ this.handleModal5 }
            />
            <MenuItem
              primaryText="Socias(os) VIP"
              leftIcon={ <ActionAssessment color='#444444'/>}
              style={{color: '#444444'}}
            />
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
                <h4 style={{color: "#2E3092"}}>Cartera Concedida</h4>
                <div className="col-xs-10" style={styles.div}>
                  <CreditosConcedidosForm
                    url='/credits/creditos_concedidos'
                    title='Consultar creditos concedidos'
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


        </div>
      </MuiThemeProvider>
    );
  }

}
WebpackerReact.setup({CreditosNavigation});