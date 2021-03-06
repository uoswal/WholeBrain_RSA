function WriteVoxels(outdir,select,results,params,varargin)
% This function will write out a single directory worth of data, where a
% directory will include all cross validation instances for all subjects for a
% particular configuration of parameters.
% The file naming convention is subject_finalholdout_cvholdout.CoordLabel.
  p = inputParser();
  addRequired(p, 'outdir');
  addRequired(p, 'select')
  addRequired(p, 'results');
  addRequired(p, 'params');
  addParameter(p, 'CoordLabel', 'mni');
  addParameter(p, 'SubjectNumberFMT', 's%d_rep.mat');
  parse(p, outdir, select, results, params, varargin{:});

  outdir    = p.Results.outdir;
  results   = p.Results.results;
  select    = p.Results.select;
  params    = p.Results.params;
  xyzlab    = p.Results.CoordLabel;
  sjfmt     = p.Results.SubjectNumberFMT;

  assert(all(structfun(@isscalar, select)|structfun(@ischar, select)));

  n = length(select);
  z = false(size(params));
  for i = 1:n
    fields = fieldnames(select);
    key = fields{i};
    val = select.(key);
    if isscalar(val)
      z = z | ([params.(key)] == val);
    elseif ischar(val)
      z = z | strcmp(val, {params.(key)});
    end
  end

  results = results(z);
  params = params(z);

  n = length(params);
  fprintf('Writing files:\n');
  for i = 1:n
    P  = params(i);
    R  = results(i);
    dt = P.data;
    fh = P.finalholdout;
    cv = P.cvholdout;
    sj = sscanf(dt, sjfmt);

    fname = sprintf('%02d_%02d_%02d.%s', sj, fh, cv, xyzlab);
    fpath = fullfile(outdir, fname);
    fprintf('%s\n', fpath);

    idx = find(strcmp(xyzlab,{R.coords.label}));
    xyz = R.coords(idx).xyz;
    disp(xyz(1:3,1:3))
    dlmwrite(fpath, xyz, ' ');
  end
  fprintf('Done.\n');
end
