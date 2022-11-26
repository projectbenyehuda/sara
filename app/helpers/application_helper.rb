module ApplicationHelper
  def options_from_query(tag)
    query = @browsing_tree['filters']['wikidata'].find{|f| f['tag'] == tag}['lookup_query']
    if query.present?
      @sparql_results = wikidata_query_as_hash(query)
      opts = []
      @sparql_results.each do |item|
        opts << [item[0], item[1]]
      end
    end
  end
  def image_for_media_type(mtype)
    case mtype
    when 'text'
      return 'text_item_pic.png'
    when 'image'
      return 'picture_pic.png'
    when 'audio'
      return 'audio_item_pic.png'
    when 'video'
      return 'video_pic.png'
    #when 'map'
    #  return 'map.png'
    when 'archive'
      return 'archive_item_pic.png'
    else
      return ''
    end
  end
  def image_for_source(source)
    case source
    when 'wikipedia'
      return 'Wikipedia_logo_24.png'
    when 'commons'
      return 'Commons_logo_24.png'
    when 'nli'
      return 'nli_logo_24.png'
    when 'pby'
      return 'pby_logo_24.png'
    when 'wikidata'
      return ''
    else
      return ''
    end
  end
end
