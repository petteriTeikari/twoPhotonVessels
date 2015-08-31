function xyz_display ( xyz_filename )

%*****************************************************************************80
%
%% XYZ_DISPLAY plots a set of points in 3D.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    07 January 2009
%
%  Author:
%
%    John Burkardt
%
%  Usage:
%
%    xyz_display ( 'filename.xyz' )
%
%  Parameters:
%
%    Input, string POINT_FILE_NAME, the name of the file 
%    containing the coordinates of the points.
%
  fprintf ( 1, '\n' );


  fprintf ( 1, '\n' );
  fprintf ( 1, 'XYZ_DISPLAY\n' );
  fprintf ( 1, '  MATLAB version\n' );
  fprintf ( 1, '\n' );
  fprintf ( 1, '  Read an XYZ file containing coordinates of points in 3D;\n' );
  fprintf ( 1, '  Display the points in a MATLAB graphics window.\n' );
%
%  First argument is the point file.
%
  if ( nargin < 1 )
    fprintf ( 1, '\n' );
    fprintf ( 1, 'XYZ_DISPLAY:\n' );
    xyz_filename = input ( '  Enter the name of the XYZ file (in ''quotes''!).\n' );
  end
%
%  Read the data.
%
  point_num = xyz_header_read (  xyz_filename );

  fprintf ( 1, '\n' );
  fprintf ( 1, '  Read the header of "%s".\n', xyz_filename );
  fprintf ( 1, '\n' );
  fprintf ( 1, '  Number of points POINT_NUM  = %d\n', point_num );

  xyz = xyz_data_read ( xyz_filename, point_num );

  fprintf ( 1, '\n' );
  fprintf ( 1, '  Read the data in "%s".\n', xyz_filename );

  r8mat_transpose_print_some ( 3, point_num, xyz, 1, 1, ...
    3, 5, '  First 5 nodes:' );

  scatter3 ( xyz(1,:), xyz(2,:), xyz(3,:), 'filled', 'b' );

  xyz_min(1) = min ( xyz(1,:) );
  xyz_max(1) = max ( xyz(1,:) );

  xyz_min(2) = min ( xyz(2,:) );
  xyz_max(2) = max ( xyz(2,:) );

  xyz_min(3) = min ( xyz(3,:) );
  xyz_max(3) = max ( xyz(3,:) );

  xyz_range(1:3) = xyz_max(1:3) - xyz_min(1:3);

  margin = 0.025 * max ( xyz_range(1), ...
                   max ( xyz_range(2), xyz_range(3) ) );

  x_min = xyz_min(1) - margin;
  x_max = xyz_max(1) + margin;
  y_min = xyz_min(2) - margin;
  y_max = xyz_max(2) + margin;
  z_min = xyz_min(3) - margin;
  z_max = xyz_max(3) + margin;

  xlabel ( '--X axis--' )
  ylabel ( '--Y axis--' )
  zlabel ( '--Z axis--' )
%
%  The TITLE function will interpret underscores in the title.
%  We need to unescape such escape sequences!
%
  title_string = s_escape_tex ( xyz_filename );
  title ( title_string )

  axis ( [ x_min, x_max, y_min, y_max, z_min, z_max ] );
  axis equal

  fprintf ( 1, '\n' );
  fprintf ( 1, 'XYZ_DISPLAY\n' );
  fprintf ( 1, '  Normal end of execution.\n' );

  fprintf ( 1, '\n' );
  
  return
end
