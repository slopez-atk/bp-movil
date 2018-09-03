import React from 'react';
import { Bar } from 'react-chartjs-2';

class Graficas extends React.Component {
  constructor(props){
    super(props)
  }


  getData(){
    let data = {
      labels: ['Diciembre', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
      datasets: [
        {
          label: this.props.titulo,
          backgroundColor: 'rgb(63, 81, 181)',
          borderColor: 'rgb(60, 76, 170)',
          borderWidth: 1,
          hoverBackgroundColor: 'rgb(46, 59, 132)',
          hoverBorderColor: 'rgb(40, 51, 113)',
          data: this.props.data
        }
      ]
    }
    return data;
  }

  render(){
    return(
      <div>
        <Bar
          data={this.getData()}
          width={80}
          height={25}/>
      </div>
    );
  }
}

export default Graficas;