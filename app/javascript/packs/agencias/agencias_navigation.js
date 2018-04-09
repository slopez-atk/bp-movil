import React from 'react';
import WebpackerReact from 'webpacker-react';


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
import ActionDns from 'material-ui/svg-icons/action/dns';
import ActionViewQuilt from 'material-ui/svg-icons/action/view-quilt';
import ActionHome from 'material-ui/svg-icons/action/home';
import Event from 'material-ui/svg-icons/action/event';
import AccountBalance from 'material-ui/svg-icons/action/account-balance';



//Colores
import {
  yellow500, yellow700,
  deepOrangeA200,
  grey100, grey300, grey400, grey500,
  white, darkBlack, fullBlack,
} from 'material-ui/styles/colors';
import IndicadoresFinancierosForm from "../../components/Agencias/AgenciasForms/IndicadoresFinancierosForm";


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

class AgenciasNavigation extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      open: false,
      openModalReporteCuentas: false,
      openModalIndicadoresSeps: false,
    };
  }



  handleToggle = () => {
    this.setState({open: !this.state.open});
  };
  handleClose = () => {
    this.setState({open: false});
  };
  handleModal1 = () => {
    this.setState({openModalReporteCuentas: !this.state.openModalReporteCuentas});
  };
  handleModal2 = () => {
    this.setState({openModalIndicadoresSeps: !this.state.openModalIndicadoresSeps});
  };

  handleLocation = (action) => {
    switch (action) {
      case 'home':
        window.location = '/agencias';
        break;

      case 'dashboard':
        window.location = '/';
        break;
    }
  };

  getMenuItems(){
    let permissions = this.props.permissions;
    return(
      <div>
        <div>
          <Divider/>
          <MenuItem
            primaryText="Indicadores Financieros"
            leftIcon={ <Event color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal1 } />

          <Divider/>

          <MenuItem
            primaryText="Indicadores de la Seps"
            leftIcon={ <AccountBalance color='#444444'/>}
            style={{color: '#444444'}}
            onClick={ this.handleModal2 } />
        </div>
      </div>

    );
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
            <Divider/>
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
              open={ this.state.openModalReporteCuentas }
              actions={actions1}
            >
              <div className="row center-xs middle-xs">
                <h4 style={{color: "#2E3092"}}>Indicadores Financieros</h4>
                <div className="col-xs-10" style={styles.div}>
                  <IndicadoresFinancierosForm
                    authenticity_token={ this.props.authenticity_token }
                    url='/agencias/indicadores_financieros'
                    title='Informe de Cuentas por Agencia'/>
                </div>
              </div>
            </Dialog>

            <Dialog
              modal={true}
              contentStyle={customContentStyle}
              open={ this.state.openModalIndicadoresSeps }
              actions={actions2}
            >
              <div className="row center-xs middle-xs">
                <h4 style={{color: "#2E3092"}}>Indicadores de la Seps</h4>
                <div className="col-xs-10" style={styles.div}>
                  <IndicadoresFinancierosForm
                    authenticity_token={ this.props.authenticity_token }
                    url='/agencias/indicadores_seps'
                    title='Informe de indicadores de la Seps'/>
                </div>
              </div>
            </Dialog>
          </div>

        </div>
      </MuiThemeProvider>
    );
  }

}
WebpackerReact.setup({AgenciasNavigation});