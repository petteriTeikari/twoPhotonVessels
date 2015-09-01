function xyz = xyz_data_read ( input_filename, point_num )
%*****************************************************************************80
%
%% XYZ_DATA_READ reads data from an XYZ file.
%
%  Discussion:
%
%    The number of points in the file can be determined by calling
%    XYZ_HEADER_READ first.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    06 February 2010
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, string INPUT_FILENAME, the name of the input file.
%
%    Input, integer POINT_NUM, the number of points.
%
%    Output, real XYZ(POINT_NUM,3), the point coordinates.
%
  input_unit = fopen ( input_filename, 'r' );

  if ( input_unit < 0 ) 
    fprintf ( 1, '\n' );
    fprintf ( 1, 'XYZ_DATA_READ - Error!\n' );
    fprintf ( 1, '  Could not open the input file "%s".\n', input_filename );
    error ( 'XYZ_DATA_READ - Error!' );
    return;
  end

  i = 0;
  %
%if the pointcloud contains normals, then set xyz=zeros(point_num, 6) 

  xyz = zeros (point_num,3 );
%
%  Use FGETL, not FGETS, so we don't pick up the NEWLINE character.
%
  while ( i < point_num )

    text = fgetl ( input_unit );

    if ( text(1) == '#' )
      continue;
    end

    if ( s_len_trim ( text ) == 0 )
      continue;
    end

    %if point cloud has normals then, [ temp, count ] = sscanf ( text, '%f %f %f %f %f %f' );
    [ temp, count ] = sscanf ( text, '%f %f %f' );

    i = i + 1;
    xyz(i,1) = temp(1);
    xyz(i,2) = temp(2);
    xyz(i,3) = temp(3);
%xyz(i,4)= temp(4);
%xyz(i,5)= temp(5);
%xyz(i,6)= temp(6);
  
  end
%
%  Close the file.
%
  fclose ( input_unit );
  return

