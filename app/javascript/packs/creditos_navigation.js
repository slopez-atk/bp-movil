import React from 'react';
import WebpackerReact from 'webpacker-react';
import CreditosPorVencerForm from '../components/CreditsForms/CreditosPorVencerForm';
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


const customContentStyle = {
  width: '100%',
  maxWidth: '850px',
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
      openModalCreditosVencer: false
    };
  }



  handleToggle = () => {
    this.setState({open: !this.state.open});
  };
  handleClose = () => {
    this.setState({open: false});
  };

  handleModal1 = () => {
    console.log(this.state.openModalCreditosVencer);
    this.setState({openModalCreditosVencer: !this.state.openModalCreditosVencer});
    console.log(this.state.openModalCreditosVencer);
  };

  handleLocation = (action) => {
    switch (action) {
      case 'home':
        this.handleClose();
        window.location = '/creditos';
      case 'dashboard':
        window.location = '/';
    }
  };


  render(){
    const actions = [
      <FlatButton
        label="Cancel"
        primary={true}
        onClick={this.handleModal1}
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
              onclick={()=> this.handleLocation('home')}
            />
            <MenuItem
              primaryText="Cartera por vencer"
              leftIcon={ <ActionAssessment color='#444444'/>}
              style={{color: '#444444'}}
              onClick={ this.handleModal1 }
            />
            <Divider/>
            <MenuItem
              primaryText="Cartera vencida"
              leftIcon={ <ActionFeedback color='#444444'/>}
              style={{color: '#444444'}}
            />
            <Divider/>
            <MenuItem
              primaryText="Matriz Transicion"
              leftIcon={ <ActionAssessment color='#444444'/>}
              style={{color: '#444444'}}
            />
            <Divider/>
            <MenuItem
              primaryText="Cosechas"
              leftIcon={ <ActionAssessment color='#444444'/>}
              style={{color: '#444444'}}
            />
            <MenuItem
              primaryText="Clientes VIP"
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
              actions={actions}
            >
              <div style={styles.div}>
                <CreditosPorVencerForm
                  authenticity_token={ this.props.authenticity_token }
                  url= '/credits/creditos_por_vencer'
                  title="Consultar creditos por vencer"/>
              </div>
            </Dialog>
          </div>

        </div>
      </MuiThemeProvider>
    );
  }

}
WebpackerReact.setup({CreditosNavigation});