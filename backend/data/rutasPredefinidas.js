// ======================================================
// DEFINICIÓN DE LAS 3 RUTAS TURÍSTICAS PREDEFINIDAS
// ======================================================
//
// Los _id son los de los sitios reales en MongoDB (listados con
// scripts/listar_sitios_para_rutas.js).
//
// duracionMin es una ESTIMACIÓN editable del tiempo de la
// actividad en cada sitio (aprobada como estimado). El tiempo de
// desplazamiento no se guarda: se calcula por carretera.
// ======================================================

const SITIOS = {
  cafeDonArnulfo: '6a864b9fa01e3dbe09911257',
  cafeEspecialPrimaveral: '6a851a3001799fc454c5302e',
  diegoCampos: '6ad8296759c4e802ac580065',
  hotelParqueLaCasona: '6a864b9fa01e3dbe0991125e',
  balconDelHuila: '6a864b9fa01e3dbe0991125b',
  cafeteriaCasetaTuristica: '6a864b9fa01e3dbe09911266',
  fincaSantaRosa: '6ad82a9159c4e802ac580067',
  cascadasLasDamas: '6a864b9fa01e3dbe0991125c',
  portalDelAngel: '6a864b9fa01e3dbe0991125f',
  trilladoraAlmaDelHuila: '6a864b9fa01e3dbe0991124b',
  catacionAromaDeMiFinca: '6a864b9fa01e3dbe09911253'
};

const RUTAS_PREDEFINIDAS = [
  {
    nombre: 'Corredor cafetero Gigante–Garzón',
    tipoExperiencia: 'cafetera',
    descripcion:
      'Recorrido cafetero de un día por la Ruta 45, desde Gigante hasta ' +
      'Garzón, con visitas cafeteras, almuerzo en el Hotel Parque La Casona ' +
      'y cierre en el Balcón del Huila al atardecer.',
    paradas: [
      { sitio: SITIOS.cafeDonArnulfo, orden: 1, tipoActividad: 'cafe', duracionMin: 60, descripcion: 'Inicio del recorrido en Gigante.' },
      { sitio: SITIOS.cafeEspecialPrimaveral, orden: 2, tipoActividad: 'cafe', duracionMin: 60 },
      { sitio: SITIOS.diegoCampos, orden: 3, tipoActividad: 'cafe', duracionMin: 60 },
      { sitio: SITIOS.hotelParqueLaCasona, orden: 4, tipoActividad: 'almuerzo', duracionMin: 75, descripcion: 'Almuerzo.' },
      { sitio: SITIOS.balconDelHuila, orden: 5, tipoActividad: 'mirador', duracionMin: 45, descripcion: 'Cierre del recorrido al atardecer.', indicaciones: 'Llegar antes del atardecer.' }
    ]
  },
  {
    nombre: 'Naturaleza y experiencia familiar',
    tipoExperiencia: 'naturaleza',
    descripcion:
      'Jornada de naturaleza y plan familiar: desayuno en Gigante, ' +
      'Finca Santa Rosa, Cascadas Las Damas y cierre en el Portal del Ángel ' +
      'Hotel Boutique.',
    paradas: [
      { sitio: SITIOS.cafeteriaCasetaTuristica, orden: 1, tipoActividad: 'desayuno', duracionMin: 45, descripcion: 'Desayuno en Gigante.' },
      { sitio: SITIOS.fincaSantaRosa, orden: 2, tipoActividad: 'visita', duracionMin: 90 },
      { sitio: SITIOS.cascadasLasDamas, orden: 3, tipoActividad: 'naturaleza', duracionMin: 90 },
      { sitio: SITIOS.portalDelAngel, orden: 4, tipoActividad: 'cierre', duracionMin: 60, descripcion: 'Cierre del recorrido.' }
    ]
  },
  {
    nombre: 'De la semilla a la taza',
    tipoExperiencia: 'cultura_cafe',
    descripcion:
      'Recorrido por la cultura del café: del cultivo al procesamiento ' +
      'y a la taza, con almuerzo en Café Don Arnulfo.',
    paradas: [
      { sitio: SITIOS.cafeDonArnulfo, orden: 1, tipoActividad: 'cafe', duracionMin: 120, descripcion: 'Cultura del café y almuerzo.' },
      { sitio: SITIOS.trilladoraAlmaDelHuila, orden: 2, tipoActividad: 'visita', duracionMin: 60 },
      { sitio: SITIOS.catacionAromaDeMiFinca, orden: 3, tipoActividad: 'cafe', duracionMin: 60, descripcion: 'La taza: catación.' }
    ]
  }
];

module.exports = { SITIOS, RUTAS_PREDEFINIDAS };
