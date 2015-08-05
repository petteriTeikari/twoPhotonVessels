function [newpt elemid weight]=proj2mesh(v,f,pt,nv,cn)
%  [newpt elemid weight]=proj2mesh(v,f,pt,nv,cn)
%
%  project a point cloud on to the surface mesh (surface can only be triangular)
%
%  author: Qianqian Fang <fangq at nmr.mgh.harvard.edu>
%  date: 12/12/2008
%
% parameters: 
%      v: node coordinate of the surface mesh (nn x 3)
%      f: element list of the surface mesh (3 columns for 
%            triangular mesh, 4 columns for cubic surface mesh)
%      pt: points to be projected, 3 columns for x,y and z respectively
%      nv: nodal norms (vector) calculated from nodesurfnorm.m
%          with dimensions of (size(v,1),3)
%      cn: a integer vector with the length of p, denoting the closest
%          surface nodes (indices of v) for each point in p. this 
%          value can be calculated from dist2surf.m
%
%      if nv and cn are not supplied, proj2mesh will project the point
%      cloud onto the surface by the direction pointing to the centroid
%      of the mesh
%
% outputs:
%      newpt: the projected points from p
%      elemid: a vector of length of p, denotes which surface trangle (in elem)
%             contains the projected point
%      weight: the barycentric coordinate for each projected points, these are
%             the weights 
%
% Please find more information at http://iso2mesh.sf.net/cgi-bin/index.cgi?metch
%
% this function is part of "metch" toobox, see COPYING for license

cent=mean(v);
enum=length(f);
ec=reshape(v(f(:,1:3)',:)', [3 3,enum]);
centroid=squeeze(mean(ec,2));
newpt =zeros(size(pt,1),3);
elemid=zeros(size(pt,1),1);
weight=zeros(size(pt,1),3);

if(nargin==5) 
       % if nv and cn are supplied, use nodal norms to project the points
       direction=nv(cn,:);
elseif(nargin==3)
       % otherwise, project toward the centroid
       direction=pt-repmat(cent,size(pt,1),1);
end

for t=1:size(pt,1)

    % calculate the distance to the centroid
    dist2=repmat(pt(t,:)',1,enum)-centroid;
    maxdist2=sum((pt(t,:)-cent).*(pt(t,:)-cent));
    c0=sum(dist2.*dist2);

    % only search for the elements that are enclosed by a sphere centered at
    % pt(t,:) passing by the centroid, this may failed under some extreme conditions,
    % which I ignored here
    idx=find(c0<maxdist2);

    % sort the distances to accelate the calculation
    [c1,sorted]=sort(c0(idx));

    for i=1:length(idx)
    
        % project the point along vector direction and calculate the intersection to a plane
	
        [inside,p,w]=linextriangle(pt(t,:), pt(t,:)+direction(t,:),v(f(idx(sorted(i)),:),:));
	
	% the intersection is within the current trianglar surface
        if(inside)
            newpt(t,:)=p;
            weight(t,:)=w;
            elemid(t)=idx(sorted(i));
            break;
        end
    end
end
