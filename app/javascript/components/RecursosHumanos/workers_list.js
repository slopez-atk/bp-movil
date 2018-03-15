import React from 'react';

import MobileTearSheet from '../CreditosPorVencer/MobileTearSheet';
import {List, ListItem} from 'material-ui/List';
import Divider from 'material-ui/Divider';
import Subheader from 'material-ui/Subheader';
import Avatar from 'material-ui/Avatar';
import FlatButton from 'material-ui/FlatButton';

import ActionAssignment from 'material-ui/svg-icons/action/assignment';
import ActionInfo from 'material-ui/svg-icons/action/info';
import {blue500} from 'material-ui/styles/colors';



class WorkersList extends React.Component {
  constructor(props){
    super(props);

  }

  getListItem(data){
    return data.map(el => {
      return (
        <div>
          <ListItem
            leftAvatar={<Avatar icon={<ActionAssignment />} backgroundColor={blue500} />}
            rightIcon={<ActionInfo onClick={() => this.handleLocation}/>}
            primaryText={el.fullname}
            secondaryText={el.cargo + " - " + el.agencia}
            onClick={() => this.handleLocation(el.id)}
          />

          <Divider inset={true} />
        </div>
      )
    });
  }

  handleLocation(id){
    window.location = "/workers/"+id;
  }

  render(){
    return(
      <List>
        <Subheader>Nómina laboral</Subheader>
        {this.getListItem(this.props.data)}
      </List>
    )
  }
}
export default WorkersList;