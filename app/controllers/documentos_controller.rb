# app/controllers/documentos_controller.rb
class DocumentosController < ApplicationController
  require "roo"

  def index
    # Não é necessário inicializar @titulo e @conteudo aqui
  end

  def enviar_arquivo
    arquivo = params[:arquivo]

    if arquivo && arquivo_valido?(arquivo)
      ler_conteudo(arquivo)
      ajustar_campos
    else
      flash[:alert] = "Arquivo inválido."
    end

    render :index  # Renderiza novamente a página de índice para exibir os resultados
  end

  private

  def arquivo_valido?(arquivo)
    def arquivo_valido?(arquivo)
        permitir_extensoes = ['.xls', '.xlsx']
        extensao = File.extname(arquivo.original_filename).downcase
        permitir_extensoes.include?(extensao)
    end
  end

  def ler_conteudo(caminho_do_arquivo)
    roo = Roo::Spreadsheet.open(caminho_do_arquivo)
    folha = roo.sheet(0)

    @dados = []

    folha.each_with_index do |linha, indice|
      linha_dados = []
      linha.each do |celula|
        linha_dados << celula
      end
      @dados << linha_dados
    end
  end

  def ajustar_campos
    ajustar_cpf
    ajustar_valor_bruto
    ajustar_total_liquido
  end

  def ajustar_cpf
    # Supondo que a coluna CPF esteja na posição 1 (índice 0)
    coluna_cpf = encontrar_coluna_por_nome(/cpf/i)

    if coluna_cpf
      @dados.each do |linha|
        cpf = linha[coluna_cpf]

        # Remover caracteres não numéricos do CPF
        cpf.gsub!(/\D/, "") if cpf

        # Adicionar o CPF ajustado de volta à linha
        linha[coluna_cpf] = cpf
      end
    else
      flash[:alert] = "Coluna não encontrada."
    end
  end

  def ajustar_total_liquido
    coluna_total_liquido = encontrar_coluna_por_nome(/total_liquido/i)

    if coluna_total_liquido
        @dados.each do |linha|
            total_liquido = linha[coluna_total_liquido]

            # Remover o R$ e substituir '.' por '_' e ',' por '.'
            total_liquido.gsub!("R$", "")
            total_liquido.gsub!(".", "_")
            total_liquido.gsub!(",", ".")

            # Adicionar o total_liquido ajustado de volta à linha
            linha[coluna_total_liquido] = total_liquido
        end
    else
        flash[:alert] = "Coluna TOTAL_LIQUIDO não encontrada."
    end
  end

  def ajustar_valor_bruto
    coluna_valor_bruto = encontrar_coluna_por_nome(/valor_bruto/i)

    if coluna_valor_bruto
        @dados.each do |linha|
            valor_bruto = linha[coluna_valor_bruto]

            # Remover o R$ e substituir '.' por '_' e ',' por '.'
            valor_bruto.gsub!("R$", "")
            valor_bruto.gsub!(".", "_")
            valor_bruto.gsub!(",", ".")

            # Adicionar o valor_bruto ajustado de volta à linha
            linha[coluna_valor_bruto] = valor_bruto
        end
    else
        flash[:alert] = "Coluna VALOR_BRUTO não encontrado."
    end
  end

  def encontrar_coluna_por_nome(nome_regex)
    coluna = @dados.first.index { |cabecalho| cabecalho =~ nome_regex }

    coluna || flash[:alert] = "Coluna #{nome_regex.inspect} não encontrada."
  end
end
