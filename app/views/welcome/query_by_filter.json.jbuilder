json.array!(@sparql_results) do |item|
  json.name item[0]
  json.qid item[1]
end