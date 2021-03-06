function WriteTable(filename,results,params,varargin)
  p = inputParser();
  addRequired(p, 'filename');
  addRequired(p, 'results');
  addRequired(p, 'params');
  addParameter(p, 'fields',{})
  addParameter(p, 'overwrite', false);
  parse(p, filename, results, params, varargin{:});

  filename  = p.Results.filename;
  results   = p.Results.results;
  params    = p.Results.params;
  fields    = p.Results.fields;
  OVERWRITE = p.Results.overwrite;

  if OVERWRITE
    fid = fopen(filename, 'w');
  else
    if exist(filename, 'file');
      error('%s already exists. To overwrite, use the set overwrite option to true.', filename);
    else
      fid = fopen(filename, 'w');
    end
  end

  % List all possible fields and their desired format code
  fieldFMT = struct( ...
    'iter'         , '%d'   , ...
    'finalholdout' , '%d'   , ...
    'cvholdout'    , '%d'   , ...
    'data'         , '%s'   , ...
    'Gtype'        , '%s'   , ...
    'lambda'       , '%.4f' , ...
    'lambda1'      , '%.4f' , ...
    'LambdaSeq'    , '%s'   , ...
    'tau'          , '%.4f' , ...
    'normalize'    , '%s'   , ...
    'bias'         , '%d'   , ...
    'p1'           , '%.4f' , ...
    'p2'           , '%.4f' , ...
    'cor1'         , '%.4f' , ...
    'cor2'         , '%.4f' , ...
    'err1'         , '%.4f' , ...
    'err2'         , '%.4f' , ...
    'FroErr1'      , '%.4f' , ...
    'FroErr2'      , '%.4f' , ...
    'nz_rows'      , '%d');

  hdrFMT = strjoin(repmat({'%s'},1,length(fields)),',');
  tmp = cellfun(@(x) fieldFMT.(x), fields, 'unif', 0);
  dataFMT = strjoin(tmp,',');
  fprintf(fid,[hdrFMT,'\n'],fields{:});

  N = length(params);
  for i = 1:N
    R = results(i);
    P = params(i);
    out = cell(1,length(fields));
    for j = 1:length(fields);
      key = fields{j};
      if isfield(P,key)
        out{j} = P.(key);
      else
        if strcmp(key,'nz_rows')
          out{j} = nnz(R.(key));
        else
          out{j} = R.(key);
        end
      end
    end
    fprintf(fid,[dataFMT,'\n'], out{:});

  end
  fclose(fid);
end
