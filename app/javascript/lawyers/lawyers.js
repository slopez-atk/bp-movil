import React from 'react';

export class Lawyers extends React.Component {

  lawyers(){
    if(this.props.lawyers){
      return this.props.lawyers.map(lawyer => {

        return(
          <tr key={lawyer.id}>
            <td data-bip-type="input" data-bip-attribute="name" data-bip-object="lawyer" data-bip-original-content={lawyer.name} data-bip-skip-blur="false" data-bip-url={'/lawyers/' + lawyer.id} data-bip-value={lawyer.name} className="best_in_place" id={"best_in_place_lawyer_" + lawyer.id +"_name"}>{lawyer.name}</td>
            <td data-bip-type="input" data-bip-attribute="lastname" data-bip-object="lawyer" data-bip-original-content={lawyer.lastname} data-bip-skip-blur="false" data-bip-url={'/lawyers/' + lawyer.id} data-bip-value={lawyer.lastname} className="best_in_place" id={"best_in_place_lawyer_" + lawyer.id +"_lastname"}>{lawyer.lastname}</td>
            <td data-bip-type="input" data-bip-attribute="phone" data-bip-object="lawyer" data-bip-original-content={lawyer.phone} data-bip-skip-blur="false" data-bip-url={'/lawyers/' + lawyer.id} data-bip-value={lawyer.phone} className="best_in_place" id={"best_in_place_lawyer_" + lawyer.id +"_phone"}>{lawyer.phone}</td>
            <td><a data-confirm="Estás seguro?" className="btn btn-danger" rel="nofollow" data-method="delete" href={'/lawyers/' + lawyer.id} >Eliminar</a></td>
          </tr>
        )
      });
    }
    return "";
  }

  render(){
    return(
      <div className="table-responsive">
        <table className="table table-striped table-hover text-center">
          <thead>
            <tr>
              <th className="text-center">Nombre</th>
              <th className="text-center">Apellido</th>
              <th className="text-center">Telefono</th>
            </tr>
          </thead>
          <tbody>
            {this.lawyers()}
          </tbody>
        </table>
      </div>
    )
  }

}