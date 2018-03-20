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
import ActionFeedback from 'material-ui/svg-icons/action/feedback';
import ActionDns from 'material-ui/svg-icons/action/dns';
import ActionViewQuilt from 'material-ui/svg-icons/action/view-quilt';
import ActionHome from 'material-ui/svg-icons/action/home';
import MapsPersonPin from 'material-ui/svg-icons/maps/person-pin';
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
  },
  floatingButton2: {
    margin: 0,
    top: 'auto',
    right: 30,
    bottom: 85,
    left: 'auto',
    position: 'fixed',
    zIndex: 10
  }
};

class RecursosHumanosNavigation extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      open: false,
    };
  }



  handleToggle = () => {
    this.setState({open: !this.state.open});
  };
  handleClose = () => {
    this.setState({open: false});
  };

  handleLocation = (action) => {
    switch (action) {
      case 'home':
        window.location = '/recursos_humanos';
        break;

      case 'dashboard':
        window.location = '/';
        break;

      case 'nuevo_trabajador':
        window.location = '/workers/new';
        break;
    }
  };

  getMenuItems(){
    let permissions = this.props.permissions;
  }

  getButtons(){
    return (
      <div>
        <FloatingActionButton style={styles.floatingButton2}  mini={true} disabled={false} onClick={ () => this.handleLocation("nuevo_trabajador") } backgroundColor="#FDD835" >
          <MapsPersonPin color="000"/>
        </FloatingActionButton>
      </div>
    )
  }


  render(){
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

          { this.getButtons() }

        </div>
      </MuiThemeProvider>
    );
  }

}
WebpackerReact.setup({RecursosHumanosNavigation});
