import React from 'react';
import WebpackerReact from 'webpacker-react';
import BalanceSocialForm from "../../components/DesepenioSocial/DesempenioForms/BalanceSocialForm";


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
import AccountCircle from 'material-ui/svg-icons/action/account-circle';


//Colores
import {
  yellow500, yellow700,
  deepOrangeA200,
  grey100, grey300, grey400, grey500,
  white, darkBlack, fullBlack,
} from 'material-ui/styles/colors';

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

class DesempenioSocialNavigation extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      open: false,
      openModalBalanceSocial: false,
    };
  }



  handleToggle = () => {
    this.setState({open: !this.state.open});
  };
  handleClose = () => {
    this.setState({open: false});
  };
  handleModal1 = () => {
    this.setState({openModalBalanceSocial: !this.state.openModalBalanceSocial});
  };

  handleLocation = (action) => {
    switch (action) {
      case 'home':
        window.location = '/desempenio_social';
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
        <Divider/>
        <MenuItem
          primaryText="Balance Social"
          leftIcon={ <AccountCircle color='#444444'/>}
          style={{color: '#444444'}}
          onClick={ this.handleModal1 } />
      </div>
    )
  }


  render(){
    const actions1 = [
      <FlatButton
        label="Cancelar"
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
              open={ this.state.openModalBalanceSocial }
              actions={actions1}
            >
              <div className="row center-xs middle-xs">
                <h4 style={{color: "#2E3092"}}>Balance Social</h4>
                <div className="col-xs-11" style={styles.div}>
                  <BalanceSocialForm
                    url='/desempenio_social/balance_social'
                    title='Balance Social'
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
WebpackerReact.setup({DesempenioSocialNavigation});