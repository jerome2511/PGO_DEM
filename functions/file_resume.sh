echo "<html>
  
<style type="text/css" media="all">

p {
      font-size: 20px; font-family:'Avenir', Helvetica, sans-serif;
    }


					.entete { color: #2979a6; font-weight: bolder; font-size: 40px; font-family: 'Avenir', Helvetica, sans-serif; }
					
					.titre  { font-weight: bolder; font-size: 40px; font-family: 'Avenir', Helvetica, sans-serif; ; text-align: center }
					
					.intitule { font-weight: bolder; font-size: 40px; font-family: 'Avenir', Helvetica, sans-serif; }
					
					.intitule2 { color: #2979a6; font-weight: bolder; font-size: 40px; font-family: 'Avenir', Helvetica, sans-serif;; text-decoration: underline }
					.description { font-size: 30px; font-family: 'Avenir', Helvetica, sans-serif; }




.tabs .tab-header {
  height:60px;
  display:flex;
  align-items:center;
}
.tabs .tab-header > div {
  width:calc(100% / 4);
  text-align:center;
  color:#888;
  
  font-weight:600;
  cursor:pointer;
  font-weight: bolder; font-size: 30px; font-family: 'Avenir', Helvetica, sans-serif; ; text-align: center 
  text-transform:uppercase;
  outline:none;
}
.tabs .tab-header > div > i {
  display:block;
  margin-bottom:5px;
}


.tabs .tab-header > div.active {
  color:#2979a6;
}


.tabs .tab-body {
  position:relative;
  height:calc(100% - 60px);
  padding:10px 5px;
}
.tabs .tab-body > div {
  position:absolute;
  top:-200%;
  opacity:0;
  transform:scale(0.9);
  transition:opacity 500ms ease-in-out 0ms,
    transform 500ms ease-in-out 0ms;
}
.tabs .tab-body > div.active {
  top:0px;
  opacity:1;
  t
}
  
</style>
<div class="tabs">
  <div class="tab-header">
    <div class="active">
      <i class="facode"></i> General informations
    </div>
 
    <div>
      <i class="facode"></i> Description
    </div>
    <div>
      <i class="facode"></i> Copyright
    </div>
  
  </div>
  
  <div class="tab-body">
    <div class="active">
      
      	<table border="0" cellpadding="0" cellspacing="0" width="100%">
											<tbody>
												<tr>
													<td width="120">
														
															<a target="_blank" title="quicklook" href="PREVIEW"><img border="0" id="imgQc" src="$7" alt="" width="700" height="700"></a>
													
													</td>
													<td width="63%">
														<table border="0" cellpadding="2" cellspacing="5">
															<tbody>
																<tr>
																	<td width="8"></td>
																	<td width="70">
																		<p class="intitule2"> DATA:</p>
																	</td>
																	<td width="20"></td>
																	<td>
																		<p class="intitule">Pl&eacute;iades DEM and orthoimage</p>
																	</td>
																</tr>
																<tr>
																	<td width="8"></td>
																	<td width="70">
																		<p class="intitule2"> FORMAT:</p>
																	</td>
																	<td width="20"></td>
																	<td>
																		<p class="intitule">TIFF</p>
																	</td>
																</tr>											
															</tbody>
														</table>
													</td>
												</tr>
											</tbody>
										</table>
      
        <table border="0" cellpadding="0" cellspacing="0" width="80%">
				<tbody>
					<tr>
						<td valign="middle" align="center">
							<br>
							<table border="0" cellpadding="0" cellspacing="0" width="100%">
								<tbody>
									<tr>
										<td valign="top">
											<table border="0" cellpadding="0" cellspacing="2" width="100%">
												<tbody>
													<tr>
														<td>
															<p> <span class="entete">DEM information</span> </p>
															<hr color="#333366">
															<p></p>
														</td>
													</tr>
												</tbody>
											</table>
											<br>
											<table border="0" cellpadding="0" cellspacing="0" width="100%">
												<tbody>
													<tr>
														<td valign="top">
															<p class="intitule"> <b>Coordinate system</b> </p>
														</td>
														<td>
															<p class="description">UTM $4 $5 - EPSG $6
																<br>
																<br> </p>
														</td>
													</tr>
													<tr>
														<td valign="top">
															<p class="intitule"> <b>Coregistration reference</b> </p>
														</td>
														<td>
															<p class="description">Copernicus Digital Elevation Model (GLO-30)
																<br>
																<br> </p>
														</td>
													</tr>
													
													<tr>
														<td valign="top">
															<p class="intitule"> <b>Correlation algorithm</b> </p>
														</td>
														<td>
															<p class="description"> "$9"
																<br>
																<br> </p>
														</td>
													</tr>
													
													
													
													
													
													
													
													
													<tr>
														<td valign="top">
															<p class="intitule"> <b>Resolution available</b> </p>
														</td>
														<td>
															<p class="description">2 m and 20 m
																<br>
																<br> </p>
														</td>
													</tr>
                          <tr>
														<td valign="top">
															<p class="intitule"> <b>Height available</b> </p>
														</td>
														<td>
															<p class="description">Ellipsoidal Height (WGS84)
																<br>
																<br> </p>
														</td>
													</tr>
												</tbody>
											</table>
										</td>
									</tr>
								</tbody>
							</table>
							<br> </td>
					</tr>
				</tbody>
			</table>
			
				<table border="0" cellpadding="0" cellspacing="0" width="80%">
				<tbody>
					<tr>
						<td valign="middle" align="center">
							<br>
							<table border="0" cellpadding="0" cellspacing="0" width="100%">
								<tbody>
									<tr>
										<td valign="top">
											<table border="0" cellpadding="0" cellspacing="2" width="100%">
												<tbody>
													<tr>
														<td>
															<p> <span class="entete">Ortho-image information</span> </p>
															<hr color="#333366">
															<p></p>
														</td>
													</tr>
												</tbody>
											</table>
											<br>
											<table border="0" cellpadding="0" cellspacing="0" width="100%">
												<tbody>
													<tr>
														<td valign="top">
															<p class="intitule"> <b>Coordinate system</b> </p>
														</td>
														<td>
															<p class="description">UTM $4 $5 - EPSG $6
																<br>
																<br> </p>
														</td>
													</tr>
													<tr>
														<td valign="top">
															<p class="intitule"> <b>Resolution available</b> </p>
														</td>
														<td>
															<p class="description">2 m for multispectral and 0.5 m for panchromatic
																<br>
																<br> </p>
														</td>
													</tr>
												</tbody>
											</table>
										</td>
									</tr>
								</tbody>
							</table>
							<br> </td>
					</tr>
				</tbody>
			</table>
			
			<table border="0" cellpadding="0" cellspacing="0" width="80%">
				<tbody>
					<tr>
						<td valign="middle" align="center">
							<br>
							<table border="0" cellpadding="0" cellspacing="0" width="100%">
								<tbody>
									<tr>
										<td valign="top">
											<table border="0" cellpadding="0" cellspacing="2" width="100%">
												<tbody>
													<tr>
														<td>
															<p> <span class="entete">Images sources</span> </p>
															<hr color="#333366">
															<p></p>
														</td>
													</tr>
												</tbody>
											</table>
											<br>
											<table border="0" cellpadding="0" cellspacing="0" width="100%">
												<tbody>
													<tr>
														<td valign="top">
															<p class="intitule"> <b>PHR</b> </p>
														</td>
														<td>
															<p class="description">$1
																<br>
																<br> </p>
														</td>
													</tr>
													<tr>
														<td valign="top">
															<p class="intitule"> <b>PHR</b> </p>
														</td>
														<td>
															<p class="description">$2
																<br>
																<br> </p>
														</td>
													</tr>
												</tbody>
											</table>
										</td>
									</tr>
								</tbody>
							</table>
							<br> </td>
					</tr>
				</tbody>
			</table>
			
    </div>
    
    
    <div>
      <h2>   </h2>
      <p>Lorem ipsum dolor sit amet consectetur adipisicing elit. Modi minus exercitationem vero, id autem fugit assumenda a molestiae numquam at, quisquam cumque. Labore eligendi perspiciatis quia incidunt quaerat ut ducimus?</p>
    </div>
    <div>
      <h2></h2>
      	<table border="0" cellpadding="0" cellspacing="2" width="100%">
												<tbody>
											
												</tbody>
											</table>
											<br>
											<table border="0" cellpadding="0" cellspacing="5" width="100%">
												<tbody>
													<tr>
														<td class="description">CNRS - LEGOS UMR5566</td>
													</tr>
												</tbody>
											</table>
    </div>
 
  </div>
</div>
  
<script>

let tabHeader = document.getElementsByClassName('tab-header')[0];
let tabIndicator = document.getElementsByClassName('tab-indicator')[0];
let tabBody = document.getElementsByClassName('tab-body')[0];

let tabsPane = tabHeader.getElementsByTagName('div');

for(let i=0;i<tabsPane.length;i++){
  tabsPane[i].addEventListener('click',function(){
    tabHeader.getElementsByClassName('active')[0].classList.remove('active');
    tabsPane[i].classList.add('active');
    tabBody.getElementsByClassName('active')[0].classList.remove('active');
    tabBody.getElementsByTagName('div')[i].classList.add('active');
    
   
  });
}

</script>
  
  
  
</html>"> $3/README_$8.html
echo $@
echo $9