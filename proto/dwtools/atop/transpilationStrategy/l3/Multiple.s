( function _Multiple_s_() {

'use strict';

let Zlib;

//

let _ = wTools;
let Parent = null;
let Self = function wTsMultiple( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'Multiple';

// --
// inter
// --

function finit()
{
  let multiple = this;
  _.Copyable.prototype.finit.call( multiple );
}

//

function init( o )
{
  let multiple = this;

  _.assert( !!o.sys.logger );

  if( !multiple.logger )
  multiple.logger = new _.Logger({ output : o.sys.logger });

  _.Copyable.prototype.init.call( multiple, o );
  Object.preventExtensions( multiple );
}

//

function form()
{
  let multiple = this;

  /* verification */

  _.assert( arguments.length === 0 );
  _.assert( _.numberInRange( multiple.optimization, [ 0, 9 ] ), 'Expects integer in range [ 0, 9 ] {-multiple.optimization-}' );
  _.assert( _.numberInRange( multiple.minification, [ 0, 9 ] ), 'Expects integer in range [ 0, 9 ] {-multiple.minification-}' );
  _.assert( _.numberInRange( multiple.diagnosing, [ 0, 9 ] ), 'Expects integer in range [ 0, 9 ] {-multiple.diagnosing-}' );
  _.assert( _.boolLike( multiple.beautifing ), 'Expects bool-like {-multiple.beautifing-}' );
  _.sure( _.arrayHas( [ 'ManyToOne', 'OneToOne' ], multiple.splittingStrategy ) );
  _.sure( _.arrayHas( [ 'preserve', 'rebuild' ], multiple.upToDate ), () => 'Unknown value of upToDate ' + _.strQuote( multiple.upToDate ) );

  /* parent */

  _.assert( multiple.formed === 0 );
  _.assert( _.objectIs( multiple.sys ) );
  _.assert( multiple.errors === null );
  _.assert( arguments.length === 0 );

  multiple.errors = [];

  multiple.onBegin = _.routinesCompose( multiple.onBegin );
  multiple.onEnd = _.routinesCompose( multiple.onEnd );

  if( !multiple.fileProvider )
  multiple.fileProvider = multiple.sys.fileProvider || _.FileProvider.Default();

  if( !multiple.logger )
  multiple.logger = new _.Logger({ output : multiple.sys.logger });

  _.assert( _.boolLike( multiple.sizeReporting ) );
  _.assert( multiple.fileProvider instanceof _.FileProvider.Abstract );
  _.assert( _.routineIs( multiple.onBegin ) );
  _.assert( _.routineIs( multiple.onEnd ) );

  multiple.formed = 1;

  // multiple.formed = 1;
  // return multiple;
  // Parent.prototype.form.call( multiple );

  let fileProvider = multiple.fileProvider;
  let path = fileProvider.path;

  /* path temp */

  multiple.outputPath = fileProvider.recordFilter( multiple.outputPath );
  multiple.inputPath = fileProvider.recordFilter( multiple.inputPath );

  multiple.outputPath.prefixPath = multiple.outputPath.prefixPath || path.current();
  multiple.inputPath.prefixPath = multiple.inputPath.prefixPath || path.current();
  multiple.inputPath.pairWithDst( multiple.outputPath );
  multiple.inputPath.pairRefine();

  // debugger;
  multiple.outputPath.form();
  multiple.inputPath.form();
  // debugger;

  multiple.tempPath = path.resolve( multiple.tempPath );

  if( multiple.writingTempFiles && multiple.tempPath )
  fileProvider.dirMake( multiple.tempPath );

  /* transpilation strategies */

  if( _.strIs( multiple.transpilingStrategies ) )
  multiple.transpilingStrategies = [ multiple.transpilingStrategies ];
  else if( !multiple.transpilingStrategies )
  multiple.transpilingStrategies = [ 'Uglify' ];
  // multiple.transpilingStrategies = [ 'Babel', 'Uglify', 'Babel' ];

  _.assert( _.strsAreAll( multiple.transpilingStrategies ) );

  for( let s = 0 ; s < multiple.transpilingStrategies.length ; s++ )
  {
    let strategy = multiple.transpilingStrategies[ s ];
    if( _.strIs( strategy ) )
    {
      _.sure( !!_.TranspilationStrategy.Transpiler[ strategy ], 'Transpiler not found', strategy )
      strategy = _.TranspilationStrategy.Transpiler[ strategy ];
    }

    if( _.routineIs( strategy ) )
    strategy = strategy({});

    multiple.transpilingStrategies[ s ] = strategy;
    _.assert( strategy instanceof _.TranspilationStrategy.Transpiler.Abstract );
  }

  /* validation */

  _.assert( _.boolLike( multiple.sizeReporting ) );
  _.assert( multiple.fileProvider instanceof _.FileProvider.Abstract );
  _.assert( _.routineIs( multiple.onBegin ) );
  _.assert( _.routineIs( multiple.onEnd ) );

  return multiple;
}

// //
//
// function perform()
// {
//   let multiple = this;
//   multiple.form();
//   multiple.perform();
//   return multiple;
// }

//

function performThen()
{
  let multiple = this;
  multiple.form();
  return multiple.perform();
}

//

function perform()
{
  let multiple = this;
  let logger = multiple.logger;
  let result = _.Consequence().take( null );
  let time = _.timeNow();

  result
  .then( function( arg )
  {
    return _.routinesCall( multiple, multiple.onBegin, [ multiple ] );
  })

  multiple.singleEach( ( single ) =>
  {
    result.then( () => single.perform() );
  });

  result
  .then( function( arg )
  {
    return _.routinesCall( multiple, multiple.onEnd, [ multiple ] );
  })
  .then( function( arg )
  {
    return _.routinesCall( multiple, multiple.onEnd, [ multiple ] );
  })
  .finally( function( err, arg )
  {
    if( err )
    _.arrayAppendOnce( multiple.errors, err );
    if( multiple.verbosity >= 1 && multiple.totalReporting )
    logger.log( ' # Transpilation took', _.timeSpent( time ) );
    return null;
  });

  return result;
}

//

function singleEach( onEach )
{
  let multiple = this;
  let sys = multiple.sys;
  let logger = multiple.logger;
  let fileProvider = multiple.fileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 1 );
  _.assert( multiple.inputPath.formed === 5 );
  _.assert( multiple.outputPath.formed === 5 );

  /* */

  try
  {

    // let found = fileProvider.filesRead
    // ({
    //   /*fileFilter*/src : multiple.inputPath,
    //   throwing : 1,
    //   recursive : 2,
    // })

    // debugger;
    let groups = fileProvider.filesFindGroups
    ({
      /*fileFilter*/src : multiple.inputPath,
      throwing : 1,
      recursive : 2,
      outputFormat : 'absolute',
    });

    // groups.filesGrouped
    // logger.log( 'Found', _.toStr( found.dstMap, { levels : 3 } ) );

    // debugger;
    for( let dstPath in groups.filesGrouped )
    {
      let srcPaths = groups.filesGrouped[ dstPath ];
      let dataMap = Object.create( null );

      if( multiple.upToDate === 'preserve' )
      {
        // debugger;
        let upToDate = fileProvider.filesAreUpToDate( dstPath, srcPaths );
        if( upToDate )
        continue;
      }

      srcPaths.map( ( srcPath ) =>
      {
        dataMap[ srcPath ] = fileProvider.fileRead( srcPath );
      });

      if( multiple.splittingStrategy === 'ManyToOne' )
      {

        let single = sys.Single
        ({
          dataMap : dataMap,
          outputPath : dstPath,
          multiple : multiple,
          sys : sys,
        });

        single.form();
        onEach( single );

      }
      else if( multiple.splittingStrategy === 'OneToOne' )
      {

        // debugger;
        for( let srcPath in dataMap )
        {

          let basePath = multiple.inputPath.basePathFor( srcPath );
          let relativePath = path.relative( basePath, srcPath );
          let outputPath = path.join( dstPath, relativePath );
          let dataMap2 = Object.create( null );
          dataMap2[ srcPath ] = dataMap[ srcPath ];

          let single = sys.Single
          ({
            dataMap : dataMap2,
            outputPath : outputPath,
            multiple : multiple,
            sys : sys,
          });

          single.form();
          onEach( single );

        }

      }
      else _.assert( 0 );

    }

  }
  catch( err )
  {
    err = _.err( err );
    throw err;
  }

// xxx
//     for( let dstPath in found.grouped )
//     {
//       let descriptor = found.grouped[ dstPath ];
//
//       if( multiple.splittingStrategy === 'ManyToOne' )
//       {
//
//         let single = sys.Single
//         ({
//           dataMap : descriptor.dataMap,
//           outputPath : dstPath,
//           multiple : multiple,
//           sys : sys,
//         });
//
//         single.form();
//         onEach( single );
//
//       }
//       else if( multiple.splittingStrategy === 'OneToOne' )
//       {
//
//         debugger;
//         for( let srcPath in descriptor.dataMap )
//         {
//
//           let basePath = multiple.inputPath.basePathFor( srcPath );
//           let relativePath = path.relative( basePath, srcPath );
//           let outputPath = path.join( dstPath, relativePath );
//           let dataMap = Object.create( null );
//           dataMap[ srcPath ] = descriptor.dataMap[ srcPath ];
//
//           let single = sys.Single
//           ({
//             dataMap : dataMap,
//             outputPath : outputPath,
//             multiple : multiple,
//             sys : sys,
//           });
//
//           single.form();
//           onEach( single );
//
//         }
//
//       }
//       else _.assert( 0 );
//
//     }
//
//   }
//   catch( err )
//   {
//     err = _.err( err );
//     throw err;
//   }
// xxx

}

// --
// relationships
// --

let Composes =
{

  // debug : 0,
  optimization : 9,
  minification : 8,
  diagnosing : 0,
  beautifing : 0,

  /* */

  writingTerminalUnderDirectory : 0,
  splittingStrategy : 'ManyToOne', /* [ 'ManyToOne', 'OneToOne' ] */
  upToDate : 'preserve', /* [ 'preserve', 'rebuild' ] */
  writingTempFiles : 0,
  writingSourceMap : 1,
  sizeReporting : 1,
  dstCounter : 0,
  srcCounter : 0,

  /* */

  inputPath : null,
  outputPath : null,
  tempPath : 'temp.tmp',

  /* */

  totalReporting : 1,
  verbosity : 4,
  onBegin : null,
  onEnd : null,

}

let Aggregates =
{
}

let Associates =
{
  sys : null,
  transpilingStrategies : null,
  fileProvider : null,
  logger : null
}

let Restricts =
{
  formed : 0,
  errors : null,
}

let Forbids =
{
}

let Accessors =
{
  transpilingStrategies : { setter : _.accessor.setter.arrayCollection({ name : 'transpilingStrategies' }) },
}

// --
// prototype
// --

let Proto =
{

  finit,
  init,
  form,
  perform,
  performThen,

  perform,
  singleEach,

  /* */

  Composes,
  Aggregates,
  Associates,
  Restricts,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.Copyable.mixin( Self );
_.Verbal.mixin( Self );

//

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

_.staticDeclare
({
  prototype : _.TranspilationStrategy.prototype,
  name : Self.shortName,
  value : Self,
});

})();
